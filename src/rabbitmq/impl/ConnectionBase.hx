package rabbitmq.impl;

import promises.Promise;

class ConnectionBase {
    public var url:String;

    public function new(url:String) {
        this.url = url;
    }

    public function connect():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::connect" not implemented'));
        });
    }

    public function close():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::close" not implemented'));
        });
    }

    public function createChannel(confirmationChannel:Bool = false):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::createChannel" not implemented'));
        });
    }
}