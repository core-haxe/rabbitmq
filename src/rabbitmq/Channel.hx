package rabbitmq;

#if nodejs

typedef Channel = rabbitmq.impl.nodejs.Channel;

#else

typedef Channel = rabbitmq.impl.fallback.Channel;

#end