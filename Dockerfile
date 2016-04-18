FROM ubuntu

MAINTAINER i@ihypo.net

RUN mkdir /app
WORKDIR /app

RUN wget https://wordpress.org/latest.tar.gz
RUN tar -zxvf wordpress-*.tar.gz

# APT自动安装PHP相关的依赖包,如需其他依赖包在此添加.
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get -yq install \
		curl \
	    apache2 \
	    libapache2-mod-php5 \
	    php5-pgsql \
	    php5-gd \
	    php5-curl \
		php-pear \
	    php-apc && \

	# 用完包管理器后安排打扫卫生可以显著的减少镜像大小.
	apt-get clean && \
	apt-get autoclean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

	# 安装Composer,此物是PHP用来管理依赖关系的工具,laravel symfony等时髦的框架会依赖它.
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Apache2配置文件:/etc/apache2/apache2.conf
# 给Apache2设置一个默认服务名,避免启动时给个提示让人紧张.
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf && \

	# PHP配置文件:etc/php5/apache2/php.ini
	# 调整PHP处理Request里变量提交值的顺序,解析顺序从左到右,后解析新值覆盖旧值.
	# 默认设定为EGPCS(ENV/GET/POST/COOKIE/SERVER)
	sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php5/apache2/php.ini


# 配置默认放置wordpress的目录
RUN mkdir -p /app/wordpress && rm -fr /var/www/html && ln -s /app/wordpress /var/www/html

RUN chmod 755 ./start.sh
RUN chmod -R 777 /wordpress
RUN chown -R www-data /var/www/html

EXPOSE 80
CMD ["./start.sh"]

ADD httpd.conf /etc/apache2/sites-enabled/000-default.conf
