package rabbitmq;

#if nodejs

typedef Channel = rabbitmq.impl.nodejs.Channel;

#elseif php

typedef Channel = rabbitmq.impl.php.Channel;

#else

typedef Channel = rabbitmq.impl.fallback.Channel;

#end