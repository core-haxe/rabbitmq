package rabbitmq.impl.nodejs;

import promises.Promise;
import rabbitmq.externs.nodejs.Connection as NativeConnection;
import rabbitmq.externs.nodejs.ConfirmChannel as NativeConfirmChannel;

class ConfirmChannel extends Channel {
    private var _nativeConfirmChannel:NativeConfirmChannel = null;
    
    public function new(connection:Connection) {
        super(connection);
        this.confirmationChannel = true;
    }

    public override function create():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            nativeConnection.createConfirmChannel((error, channel) -> {
                if (error != null) {
                    reject(new RabbitMQError(error.name, error.message));
                    return;
                }

                _nativeConfirmChannel = channel;
                resolve(new RabbitMQResult(connection, true, this));
            });
        });
    }
}