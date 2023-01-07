package rabbitmq;

class RabbitMQResult<T> {
    public var connection:Connection;
    public var data:T;
    public var channel:Channel;
    public var exchange:Exchange;
    public var queue:Queue;

    public function new(connection:Connection, data:T = null, channel:Channel = null, exchange:Exchange = null, queue:Queue = null) {
        this.connection = connection;
        this.data = data;
        this.channel = channel;
        this.exchange = exchange;
        this.queue = queue;
    }
}