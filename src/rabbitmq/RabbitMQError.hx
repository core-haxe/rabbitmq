package rabbitmq;

class RabbitMQError {
    public var name:String;
    public var message:String;

    public function new(name:String, message:String) {
        this.name = name;
        this.message = message;
    }
}