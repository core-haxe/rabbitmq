package rabbitmq.impl.nodejs;

import haxe.io.Bytes;
import promises.Promise;
import rabbitmq.externs.nodejs.Channel as NativeChannel;
import rabbitmq.externs.nodejs.ConfirmChannel as NativeConfirmChannel;

@:access(rabbitmq.impl.nodejs.Message)
class Queue extends QueueBase {
    private var consumerTag:String;

    public override function create(?options:QueueOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (confirmationChannel) {
                nativeConfirmChannel.assertQueue(this.name, options, (error, details) -> {
                    if (error != null) {
                        reject(new RabbitMQError(error.name, error.message));
                        return;
                    }

                    this.name = details.queue;
                    this.messageCount = details.messageCount;
                    this.consumerCount = details.consumerCount;

                    resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
                });
            } else {
                nativeChannel.assertQueue(this.name, options, (error, details) -> {
                    if (error != null) {
                        reject(new RabbitMQError(error.name, error.message));
                        return;
                    }

                    this.name = details.queue;
                    this.messageCount = details.messageCount;
                    this.consumerCount = details.consumerCount;

                    resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
                });
            }
        });
    }

    public override function consume(?options:ConsumeOptions):Promise<RabbitMQResult<Message>> {
        return new Promise((resolve, reject) -> {
            if (confirmationChannel) {
                nativeConfirmChannel.consume(this.name, (nativeMessage) -> {
                    var message = new Message(nativeMessage.content.toBytes());
                    message.channel = this.channel;
                    message.nativeMessage = nativeMessage;
                    resolve(new RabbitMQResult(channel.connection, message, channel, null, this));
                }, options);
            } else {
                nativeChannel.consume(this.name, (nativeMessage) -> {
                    var message = new Message(nativeMessage.content.toBytes());
                    message.channel = this.channel;
                    message.nativeMessage = nativeMessage;
                    resolve(new RabbitMQResult(channel.connection, message, channel, null, this));
                }, options);
            }
        });
    }

    public override function startConsuming(?options:ConsumeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (confirmationChannel) {
                nativeConfirmChannel.consume(this.name, (nativeMessage) -> {
                    var message = new Message(nativeMessage.content.toBytes());
                    message.channel = this.channel;
                    message.nativeMessage = nativeMessage;
                    if (_onMessage != null) {
                        _onMessage(message);
                    }
                }, options, (error, response) -> {
                    consumerTag = response.consumerTag;
                    resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
                });
            } else {
                nativeChannel.consume(this.name, (nativeMessage) -> {
                    var message = new Message(nativeMessage.content.toBytes());
                    message.channel = this.channel;
                    message.nativeMessage = nativeMessage;
                    if (_onMessage != null) {
                        _onMessage(message);
                    }
                }, options, (error, response) -> {
                    consumerTag = response.consumerTag;
                    resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
                });
            }
        });
    }

    public override function stopConsuming():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (consumerTag == null) {
                resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
            } else {
                if (confirmationChannel) {
                    nativeConfirmChannel.cancel(consumerTag, (error, ok) -> {
                        consumerTag = null;
                        resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
                    });
                } else {
                    nativeChannel.cancel(consumerTag, (error, ok) -> {
                        consumerTag = null;
                        resolve(new RabbitMQResult(channel.connection, true, channel, null, this));
                    });
                }
            }
        });
    }

    private var confirmationChannel(get, null):Bool;
    private function get_confirmationChannel():Bool {
        return cast(channel, Channel).confirmationChannel;
    }

    private var nativeChannel(get, null):NativeChannel;
    private function get_nativeChannel():NativeChannel {
        return @:privateAccess cast(channel, Channel)._nativeChannel;
    }
    
    private var nativeConfirmChannel(get, null):NativeConfirmChannel;
    private function get_nativeConfirmChannel():NativeConfirmChannel {
        return @:privateAccess cast(channel, ConfirmChannel)._nativeConfirmChannel;
    }
}