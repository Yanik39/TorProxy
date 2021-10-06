FROM python:slim

ENV	DEBIAN_FRONTEND="noninteractive" \
	TERM="xterm-256color" \
	LC_ALL=C.UTF-8
	
RUN apt-get update -qq && apt-get upgrade -y --with-new-pkgs -qq \
	&& apt-get install -y --no-install-recommends -qq apt-utils \
		apt-transport-https ca-certificates gnupg curl wget bash		 

COPY root/ /

RUN cd /tmp \
	&& curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import \
	&& gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - \
	&& apt-get update -qq && apt-get upgrade -y --with-new-pkgs -qq \
	&& apt-get install -y --no-install-recommends --no-install-suggests -qq \
		deb.torproject.org-keyring tor obfs4proxy torsocks tor-geoipdb \
		dnsmasq nano net-tools dnsutils zip unzip expect \
	&& apt-get update -qq && apt-get upgrade -y --with-new-pkgs -qq \
	&& apt-get clean autoclean -qq && apt-get autoremove -y -qq \
	&& /usr/local/bin/python3 -m pip install --upgrade pip \
	&& /usr/local/bin/python3 -m pip install stem ipaddr nyx supervisor \
	&& rm -rf /var/lib/apt/* /var/lib/cache/* /var/lib/log/* /tmp/* /var/tmp/* /var/log/* \
		/usr/share/doc/ /usr/share/man/ /usr/share/locale/ /root/.cache /root/.gnupg \
	&& groupadd tor && useradd -ms /bin/bash -g tor tor \
	&& chown -R tor:tor /home/tor /usr/local/tor \
	&& chmod 600 /help/supervisord.conf \
	&& chmod 644 /help/bashrc /help/resolv.conf /help/dnsmasq.conf \
	&& chmod 700 /TORNet /help/check_updates.sh help/fix_permissions.sh \
		/help/supervisor_secrets.sh /usr/local/bin/torlog \
	&& chmod 777 /help/Health*	

HEALTHCHECK --interval=2m --timeout=39s --start-period=3m --retries=10 \
	CMD ["/bin/bash","-c","/help/HealthCheck"]
	
ENTRYPOINT ["/TorProxy"]
