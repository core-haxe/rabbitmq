package rabbitmq.impl.nodejs;

import haxe.io.Bytes;
import promises.Promise;
import rabbitmq.externs.nodejs.Exchange as NativeExchange;
import rabbitmq.externs.nodejs.Channel as NativeChannel;
import rabbitmq.externs.nodejs.ConfirmChannel as NativeConfirmChannel;
import rabbitmq.externs.nodejs.PublishOptions as NativePublishOptions;

class Exchange extends ExchangeBase {
    private var _nativeExchange:NativeExchange = null;

    private var _autoReconnectOptions:ExchangeOptions = null;

    public override function create(?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        _autoReconnectOptions = options;
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
                try {
                    nativeChannel.publish(this.name, routingKey, messageContent, nativeOptions);
                    resolve(new RabbitMQResult(channel.connection, message, channel, this));
                } catch (e:Dynamic) {
                    checkDisconnection(e).then(reconnected -> {
                        if (reconnected) {
                            trace("republishing message after reconnection");
                            publish(message, routingKey, options).then(publishResult -> {
                                resolve(publishResult);
                            }, error -> {
                                reject(error);
                            });
                        } else {
                            reject(new RabbitMQError("could not auto reconnected after disconnection", "could not auto reconnected after disconnection"));
                        }
                    }, error -> {
                        reject(new RabbitMQError(error, error));
                    });
                }
            }
        });
    }

    private function checkDisconnection(exception:Dynamic):Promise<Bool> {
        return new Promise((resolve, reject) -> {
            var exceptionString = Std.string(exception);
            if (ConnectionManager.autoReconnect && exceptionString == "IllegalOperationError: Channel closed") { // TODO: flakey error recognition
                attemptReconnect().then(_ -> {
                    resolve(true);
                }, error -> {
                    trace("error", error);
                });
            } else { // if we arent setup for reconnection, we'll reject and handle as a normal error
                reject(exception);
            }
        });
    }

    private function attemptReconnect():Promise<Bool> {
        return new Promise((resolve, reject) -> {
            haxe.Timer.delay(() -> {
                _attemptReconnect(resolve, reject);
            }, ConnectionManager.autoReconnectIntervalMS);
        });
    }

    private function _attemptReconnect(resolve:Bool->Void, reject:Any->Void) {
        trace("connection dropped, attempting to reconnect");
        // we'll force a new connection here, not technically need since the connection manager
        // will automatically clean itself up, but this is an added level of being sure
        ConnectionManager.instance.getConnection(channel.connection.url, true).then(connection -> {
            // we'll need to rebuild the channel and update the references in this exchange
            // since all the old references are now stale and no longer valid
            if (confirmationChannel) {
                var confirmChannel = new ConfirmChannel(connection);
                return confirmChannel.create();
            }
            var channel = new Channel(connection);
            return channel.create();
        }).then(result -> {
            this.channel = result.channel;
            return this.create(_autoReconnectOptions);
        }).then(_ -> {
            trace("reconnected successfully after dropped connection");
            resolve(true);
        }, error -> {
            haxe.Timer.delay(() -> {
                _attemptReconnect(resolve, reject);
            }, ConnectionManager.autoReconnectIntervalMS);
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