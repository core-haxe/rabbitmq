package rabbitmq;

#if nodejs

typedef Exchange = rabbitmq.impl.nodejs.Exchange;

#else

typedef Exchange = rabbitmq.impl.fallback.Exchange;

#end