package rabbitmq;

#if nodejs

typedef Exchange = rabbitmq.impl.nodejs.Exchange;

#elseif php

typedef Exchange = rabbitmq.impl.php.Exchange;

#else

typedef Exchange = rabbitmq.impl.fallback.Exchange;

#end