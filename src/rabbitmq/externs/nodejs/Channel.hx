package rabbitmq.externs.nodejs;

import js.lib.Error;

@:jsRequire("amqplib/callback_api", "Channel")
extern class Channel {
    public function assertExchange(exchange:String, type:ExchangeType, ?options:ExchangeOptions, ?callback:Error->Bool->Void):Void;
    public function bindQueue(queue:String, source:String, pattern:String, ?args:Dynamic, ?callback:Error->Bool->Void):Void;
    public function assertQueue(?name:String, ?options:QueueOptions, ?callback:Error->QueueDetails->Void):Void;
    public function publish(exchange:String, routingKey:String, buffer:BytesBuffer, ?options:PublishOptions):Void;
    public function sendToQueue(name:String, buffer:BytesBuffer, ?options:SendOptions):Void;
    public function consume(name:String, messageCallback:Message->Void, ?options:ConsumeOptions, ?callback:Error->Dynamic->Void):Void;
    public function cancel(consumerTag:String, ?callback:Error->Dynamic->Void):Void;
    public function prefetch(count:Int):Void;
    public function ack(message:Message, ?allUpTo:Bool):Void;
    public function ackAll():Void;
    public function nack(message:Message, ?allUpTo:Bool, ?requeue:Bool):Void;
    public function nackAll(?requeue:Bool):Void;
    public function close(?callback:Error->Void):Void;
}