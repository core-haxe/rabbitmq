package rabbitmq.impl.nodejs;

import promises.Promise;
import rabbitmq.externs.nodejs.RabbitMQ;
import rabbitmq.externs.nodejs.Connection as NativeConnection;

class Connection extends ConnectionBase {
    private var _nativeConnection:NativeConnection = null;

    public override function connect():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            RabbitMQ.connect(this.url, (error, connection) -> {
                if (error != null) {
                    reject(new RabbitMQError(error.name, error.message));
                    return;
                }

                _nativeConnection = connection;
                resolve(new RabbitMQResult(this, true));
            });
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
        if (confirmationChannel) {
            var confirmChannel = new ConfirmChannel(this);
            return confirmChannel.create();
        }
        var channel = new Channel(this);
        return channel.create();
    }
}