package rabbitmq;

#if nodejs

typedef Connection = rabbitmq.impl.nodejs.Connection;

#else

typedef Connection = rabbitmq.impl.fallback.Connection;

#end