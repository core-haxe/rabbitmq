package rabbitmq;

#if nodejs

typedef Connection = rabbitmq.impl.nodejs.Connection;

#elseif php

typedef Connection = rabbitmq.impl.php.Connection;

#else

typedef Connection = rabbitmq.impl.fallback.Connection;

#end