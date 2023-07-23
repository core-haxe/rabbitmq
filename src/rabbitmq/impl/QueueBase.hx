package rabbitmq.impl;

import promises.Promise;

class QueueBase {
    public var channel:Channel;
    public var name:String;
    public var messageCount:Int;
    public var consumerCount:Int;

    public function new(channel:Channel, ?name:String) {
        this.channel = channel;
        this.name = name;
        if (this.name == null) {
            this.name = "";
        }
    }

    public function create(?options:QueueOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::create" not implemented'));
        });
    }

    public function consume(?options:ConsumeOptions):Promise<RabbitMQResult<Message>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::consume" not implemented'));
        });
    }

    private var _onMessage:Message->Void;
    public var onMessage(get, set):Message->Void;
    private function get_onMessage():Message->Void {
        return _onMessage;
    }
    private function set_onMessage(value:Message->Void):Message->Void {
        _onMessage = value;
        return value;
    }

    public function startConsuming(?options:ConsumeOptions):Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::startConsuming" not implemented'));
        });
    }

    public function stopConsuming():Promise<RabbitMQResult<Bool>> {
        return new Promise((resolve, reject) -> {
            reject(new RabbitMQError("not implemented", 'function "${Type.getClassName(Type.getClass(this))}::startConsuming" not implemented'));
        });
    }
}