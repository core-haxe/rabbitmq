# rabbitmq
rabbitmq for all relevant haxe targets

# basic usage

```haxe
var connection = new Connection("amqp://localhost");
connection.connect().then(result -> {
    return result.connection.createChannel(false); // can optionally create confirmation channels also
}).then(result -> {
    return result.channel.createExchange("logs", ExchangeType.Direct, { durable: true, alternateExchange: "logs.deadletter" });
}).then(result -> {
    return result.exchange.createBoundQueue("logs-q", { exclusive: false });
}).then(result -> {
    result.queue.onMessage = (message:Message) -> {
        trace(message.content);
        message.ack();
    }
    result.queue.startConsuming({noAck: false});
}, (error:RabbitMQError) -> {
    connection.close();
    // error
});
```

# a note about `RetryableQueue`

A class is included in this lib `RetryableQueue`. This is not part of the standard RabbitMQ api, it is however a pretty common EIP, so the decision was made to include it in the base library. Its fairly simple:

* create a worker queue
* create a retry queue that will feed the worker queue when a message on it expires
* optionally specify an exchange (if not each queue pair will have their own exchange)
* optionally specify a ttl for all messages that hit the retry queue (smallest wins between message ttl and queue ttl)

The retry queue is set to post messages back to the worker queue when they expire (via `x-dead-letter-exchange`). If you post a message to the retry queue with a ttl (of if a queue ttl is setup) it will expire after that ttl and enter the back of the worker queue. This means that if you want to retry a message after, say, 10 seconds you can just call `retry(message, 10000)` on the queue, and will mean the queue itself isnt stuck waiting (as it would be with a timer) and is free to process other messages.
