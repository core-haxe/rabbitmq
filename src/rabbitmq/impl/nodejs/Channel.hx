package rabbitmq.impl.nodejs;

import rabbitmq.externs.nodejs.BytesBuffer;
import haxe.io.Bytes;
import promises.Promise;
import rabbitmq.externs.nodejs.Channel as NativeChannel;
import rabbitmq.externs.nodejs.Connection as NativeConnection;
import rabbitmq.externs.nodejs.Message as NativeMessage;

@:access(rabbitmq.impl.nodejs.Message)
class Channel extends ChannelBase {
    private var _nativeChannel:NativeChannel = null;
    public var confirmationChannel:Bool = false;

    public override function create():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            nativeConnection.createChannel((error, channel) -> {
                if (error != null) {
                    reject(new RabbitMQError(error.name, error.message));
                    return;
                }

                _nativeChannel = channel;
                resolve(new RabbitMQResult(connection, true, this));
            });
        });
    }

    public override function createQueue(?name:String, ?options:QueueOptions):Promise<RabbitMQResult<Bool>> {
        var queue = new Queue(this, name);
        return queue.create(options);
    }

    public override function createExchange(name:String, type:ExchangeType, ?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        var exchange = new Exchange(this, name, type);
        return exchange.create(options);
    }

    public function prefetch(count:Int) {
        _nativeChannel.prefetch(count);
    }

    public override function ack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var nativeMessage:NativeMessage = message.nativeMessage;
                _nativeChannel.ack(nativeMessage);
                resolve(new RabbitMQResult(connection, true, this));
            } catch (e:Dynamic) {
                checkDisconnection(e).then(reconnected -> {
                    if (reconnected) {
                        /* we dont actually need to re-ack since the channel has been closed
                        trace("acking message after reconnection");
                        ack(message).then(ackResult -> {
                            resolve(ackResult);
                        }, error -> {
                            reject(error);
                        });
                        */
                    } else {
                        reject(new RabbitMQError("could not auto reconnected after disconnection", "could not auto reconnected after disconnection"));
                    }
                }, error -> {
                    reject(new RabbitMQError(error, error));
                });
            }
        });
    }

    public override function nack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var nativeMessage:NativeMessage = message.nativeMessage;
                _nativeChannel.nack(nativeMessage);
                resolve(new RabbitMQResult(connection, true, this));
            } catch (e:Dynamic) {
                checkDisconnection(e).then(reconnected -> {
                    if (reconnected) {
                        /* we dont actually need to re-ack since the channel has been closed
                        trace("acking message after reconnection");
                        ack(message).then(ackResult -> {
                            resolve(ackResult);
                        }, error -> {
                            reject(error);
                        });
                        */
                    } else {
                        reject(new RabbitMQError("could not auto reconnected after disconnection", "could not auto reconnected after disconnection"));
                    }
                }, error -> {
                    reject(new RabbitMQError(error, error));
                });
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
        ConnectionManager.instance.getConnection(connection.url, true).then(connection -> {
            // we'll need to rebuild the channel and update the references in this exchange
            // since all the old references are now stale and no longer valid
            this.connection = connection;
            return create();
        }).then(result -> {
            trace("reconnected successfully after dropped connection");
            resolve(true);
        }, error -> {
            haxe.Timer.delay(() -> {
                _attemptReconnect(resolve, reject);
            }, ConnectionManager.autoReconnectIntervalMS);
        });
    }

    public override function close():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (_nativeChannel == null) {
                resolve(new RabbitMQResult(connection, true, this));            
            } else {
                _nativeChannel.close((error) -> {
                    _nativeChannel = null;
                    resolve(new RabbitMQResult(connection, true, this));            
                });
            }
        });
    }

    public override function sendToQueue(name:String, bytes:Bytes):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            _nativeChannel.sendToQueue(name, BytesBuffer.fromBytes(bytes));
            resolve(new RabbitMQResult(connection, true, this));
        });
    }

    private var nativeConnection(get, null):NativeConnection;
    private function get_nativeConnection():NativeConnection {
        return @:privateAccess cast(connection, Connection)._nativeConnection;
    }
}