package rabbitmq.impl.php;

import phpAmqpLib.connection.AMQPStreamConnection;
import promises.Promise;

class Connection extends ConnectionBase {
    private var _nativeConnection:AMQPStreamConnection;

    public override function connect():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            try {
                var connection = new AMQPStreamConnection('localhost', 5672, 'guest', 'guest');
                _nativeConnection = connection;
                resolve(new RabbitMQResult(this, true));
            } catch (e:Dynamic) {
                reject(new RabbitMQError(e, e));
            }
        });
    }

    public override function close():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            if (_nativeConnection != null) {
                _nativeConnection.close();
            }
            resolve(new RabbitMQResult(this, true));
        });
    }

    public override function createChannel(confirmationChannel:Bool = false):Promise<RabbitMQResult<Bool>> {
        var channel = new Channel(this);
        return channel.create();
    }
}