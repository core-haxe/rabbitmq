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
            var nativeMessage:NativeMessage = message.nativeMessage;
            _nativeChannel.ack(nativeMessage);
            resolve(new RabbitMQResult(connection, true, this));
        });
    }

    public override function nack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            var nativeMessage:NativeMessage = message.nativeMessage;
            _nativeChannel.nack(nativeMessage);
            resolve(new RabbitMQResult(connection, true, this));
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