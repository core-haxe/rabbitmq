package rabbitmq.externs.nodejs;

extern typedef QueueDetails = {
    var queue:String;
    var messageCount:Int;
    var consumerCount:Int;
}