author: TianChi Date: 2015-12
# using transmission as frondend content producer agent
    BitTorrent file download linux client

# scm && provision
    check out code: 
        mkdir -p Data && cd /Data && git clone https://numenshane@github.com/numenshane/transmission
    autoprovision
        sh -x auto_provision.sh
    # First: install tranmission service 
        BitTorrent Client: transmission installation for centos6:(etc. v2.84) 
            cd /etc/yum.repos.d && wget http://geekery.altervista.org/geekery-el6-x86_64.repo
            wget http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
            rpm -ivh rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm
            yum install transmission transmission-daemon -y
    # configuration && deploy (future merge into auto_provision.sh)
        vi /etc/sysconfig/transmission-daemon
            DAEMON_ARGS="-t -g /var/lib/transmission/.config/transmission-daemon -e /var/log/transmission/transmission.log" 
        mkdir -p /var/log/transmission
        mkdir -p /var/lib/transmission/.config/transmission-daemon
        # 权限
        chown -R transmission:transmission /var/lib/transmission/.config/  
        chown -R transmission:transmission /var/log/transmission
        # 初次启动服务，在设置的目录下生成对应配置文件 /var/lib/transmission/.config/transmission-daemon/settings.json 
            systemctl start transmission-daemon
            systemctl stop transmission-daemon
        # 确保daemon服务已关闭，才能修改settings.json的授权 密码
        vi /var/lib/transmission/.config/transmission-daemon/settings.json
            "download-dir": "/var/lib/transmission/Downloads", 
            "rpc-authentication-required": true,
            "rpc-enabled": true,
            "rpc-username": "userName",
            "rpc-password": "Passwd",
            "rpc-whitelist": "127.0.0.1",
            "rpc-whitelist-enabled": false, 
            "rpc-port": 9091,
            "peer-port": 51413,
            "peer-port-random-on-start": false,
    # restart transmission-daemon service
        service transmission-daemon restart

# web UI
    http://${HostIp}:${rpc-port}
    login && upload BitTorrent file or Magnet link
# CLI
    transmission-remote ${ip}:{port} --auth ${user}:${passwd} -a "${maglink url}" # upload maglink
    transmission-remote ${ip}:{port} --auth ${user}:${passwd} -l # list maglink files
    
