package rabbitmq.impl.nodejs;

import haxe.io.Bytes;
import promises.Promise;
import rabbitmq.externs.nodejs.Exchange as NativeExchange;
import rabbitmq.externs.nodejs.Channel as NativeChannel;
import rabbitmq.externs.nodejs.ConfirmChannel as NativeConfirmChannel;
import rabbitmq.externs.nodejs.PublishOptions as NativePublishOptions;

class Exchange extends ExchangeBase {
    private var _nativeExchange:NativeExchange = null;

    public override function create(?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            var type:String = this.type;
            if (confirmationChannel) {
                nativeConfirmChannel.assertExchange(this.name, type, options, (error, success) -> {
                    if (error != null) {
                        reject(new RabbitMQError(error.name, error.message));
                        return;
                    }

                    resolve(new RabbitMQResult(channel.connection, true, channel, this));
                });
            } else {
                nativeChannel.assertExchange(this.name, type, options, (error, success) -> {
                    if (error != null) {
                        reject(new RabbitMQError(error.name, error.message));
                        return;
                    }

                    resolve(new RabbitMQResult(channel.connection, true, channel, this));
                });
            }
        });
    }

    public override function createBoundQueue(?name:String, ?options:QueueOptions, ?pattern:String):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (confirmationChannel) {
                var queue = new Queue(this.channel, name);
                queue.create(options).then(result -> {
                    nativeConfirmChannel.bindQueue(result.queue.name, this.name, pattern, null, (error, success) -> {
                        resolve(new RabbitMQResult(channel.connection, true, channel, this, queue));
                    });
                }, (error:RabbitMQError) -> {
                    reject(error);
                });
            } else {
                var queue = new Queue(this.channel, name);
                queue.create(options).then(result -> {
                    nativeChannel.bindQueue(result.queue.name, this.name, pattern, null, (error, success) -> {
                        resolve(new RabbitMQResult(channel.connection, true, channel, this, queue));
                    });
                }, (error:RabbitMQError) -> {
                    reject(error);
                });
            }
        });
    }

    public override function publish(message:Message, ?routingKey:String, ?options:PublishOptions):Promise<RabbitMQResult<Message>> {
        return new Promise((resolve, reject) -> {
            if (routingKey == null) {
                routingKey = "";
            }
            var nativeOptions:NativePublishOptions = { };
            var messageOptions:MessageOptions = message.options;
            if (messageOptions == null) {
                messageOptions = {};
            }
            if (options == null) {
                options = {};
            }

            nativeOptions.expiration = messageOptions.expiration;
            nativeOptions.userId = options.userId;
            nativeOptions.CC = options.CC;
            nativeOptions.priority = messageOptions.priority;
            nativeOptions.persistent = messageOptions.persistent;
            nativeOptions.mandatory = messageOptions.mandatory;
            nativeOptions.BCC = options.BCC;
            nativeOptions.contentType = messageOptions.contentType;
            nativeOptions.contentEncoding = messageOptions.contentEncoding;
            nativeOptions.headers = message.headersToObject();
            nativeOptions.correlationId = messageOptions.correlationId;
            nativeOptions.replyTo = messageOptions.replyTo;
            nativeOptions.messageId = messageOptions.messageId;
            nativeOptions.timestamp = messageOptions.timestamp;
            nativeOptions.type = messageOptions.type;
            nativeOptions.appId = messageOptions.appId;

            var messageContent:Bytes = message.content;
            if (confirmationChannel) {
                nativeConfirmChannel.publish(this.name, routingKey, messageContent, nativeOptions, (error, success) -> {
                    if (error != null) {
                        reject(new RabbitMQError(error.name, error.message));
                        return;
                    }

                    resolve(new RabbitMQResult(channel.connection, message, channel, this));
                });
            } else {
                nativeChannel.publish(this.name, routingKey, messageContent, nativeOptions);
                resolve(new RabbitMQResult(channel.connection, message, channel, this));
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