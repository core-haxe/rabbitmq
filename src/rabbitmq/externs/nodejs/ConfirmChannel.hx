package rabbitmq.externs.nodejs;

import js.lib.Error;

@:jsRequire("amqplib/callback_api", "ConfirmChannel")
extern class ConfirmChannel {
    public function assertExchange(exchange:String, type:ExchangeType, ?options:ExchangeOptions, ?callback:Error->Bool->Void):Void;
    public function bindQueue(queue:String, source:String, pattern:String, ?args:Dynamic, ?callback:Error->Bool->Void):Void;
    public function assertQueue(?name:String, ?options:QueueOptions, ?callback:Error->QueueDetails->Void):Void;
    public function publish(exchange:String, routingKey:String, buffer:BytesBuffer, ?options:PublishOptions, ?callback:Error->Bool->Void):Void;
    public function sendToQueue(name:String, buffer:BytesBuffer, ?options:SendOptions, ?callback:Error->Bool->Void):Void;
    public function consume(name:String, messageCallback:Message->Void, ?options:ConsumeOptions, ?callback:Error->Bool->Void):Void;
    public function prefetch(count:Int):Void;
    public function ack(message:Message, ?allUpTo:Bool):Void;
    public function ackAll():Void;
    public function nack(message:Message, ?allUpTo:Bool, ?requeue:Bool):Void;
    public function nackAll(?requeue:Bool):Void;
}