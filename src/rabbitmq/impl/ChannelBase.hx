package rabbitmq.impl;

import haxe.io.Bytes;
import promises.Promise;

class ChannelBase {
    public var connection:Connection;

    public function new(connection:Connection) {
        this.connection = connection;
    }

    public function create():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::create" not implemented'));
        });
    }

    public function createQueue(?name:String, ?options:QueueOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::createQueue" not implemented'));
        });
    }

    public function createExchange(name:String, type:ExchangeType, ?options:ExchangeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::createExchange" not implemented'));
        });
    }

    public function ack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::ack" not implemented'));
        });
    }

    public function nack(message:Message):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::nack" not implemented'));
        });
    }

    public function sendToQueue(name:String, bytes:Bytes):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::sendToQueue" not implemented'));
        });
    }

    public function close():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::close" not implemented'));
        });
    }
}
