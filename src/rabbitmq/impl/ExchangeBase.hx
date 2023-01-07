package rabbitmq.impl;

import promises.Promise;

class ExchangeBase {
    public var channel:Channel;
    public var name:String;
    public var type:ExchangeType;

    public function new(channel:Channel, name:String, type:ExchangeType) {
        this.channel = channel;
        this.name = name;
        this.type = type;
    }

    public function create(?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::create" not implemented'));
        });
    }

    public function createBoundQueue(?name:String, ?options:QueueOptions, ?pattern:String):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::createBoundQueue" not implemented'));
        });
    }

    public function publish(message:Message, ?routingKey:String, ?options:PublishOptions):Promise<RabbitMQResult<Message>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::publish" not implemented'));
        });
    }
}