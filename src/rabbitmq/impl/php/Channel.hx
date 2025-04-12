package rabbitmq.impl.php;

import phpAmqpLib.message.AMQPMessage;
import phpAmqpLib.connection.AMQPStreamConnection;
import phpAmqpLib.channel.AMQPChannel;
import promises.Promise;

class Channel extends ChannelBase {
    private var _nativeChannel:AMQPChannel = null;

    public override function create():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var channel = nativeConnection.channel();
                _nativeChannel = channel;
                resolve(new RabbitMQResult(connection, true, this));
            } catch (e:Dynamic) {
                reject(new RabbitMQError(e, e));
            }
        });
    }

    public override function close():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (_nativeChannel == null) {
                resolve(new RabbitMQResult(connection, true, this));            
            } else {
                _nativeChannel.close();
                resolve(new RabbitMQResult(connection, true, this));            
            }
        });
    }

    public override function createExchange(name:String, type:ExchangeType, ?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        var exchange = new Exchange(this, name, type);
        return exchange.create(options);
    }

    public function prefetch(count:Int) {
        _nativeChannel.basic_qos(0, count, false);
    }

    public override function ack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            var nativeMessage:AMQPMessage = message.nativeMessage;
            nativeMessage.ack();
            resolve(new RabbitMQResult(connection, true, this));
        });
    }

    public override function nack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            var nativeMessage:AMQPMessage = message.nativeMessage;
            nativeMessage.nack();
            resolve(new RabbitMQResult(connection, true, this));
        });
    }

    private var nativeConnection(get, null):AMQPStreamConnection;
    private function get_nativeConnection():AMQPStreamConnection {
        return @:privateAccess cast(connection, Connection)._nativeConnection;
    }
}