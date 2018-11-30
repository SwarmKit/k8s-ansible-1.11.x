參考《和我一步步部署 KUBERNETES 集群》，將其部署步驟通過ansible playbook實現自動化部署。
https://www.gitbook.com/book/opsnull/follow-me-install-kubernetes-cluster/details

1. 環境要求
實驗環境通過XEN 建立了6臺虛擬機器(centos 7)進行部署，其中1台配置為k8s ansible,2臺為kube-master，其他3台配置為k8s nodes。可以根據實際環境擴展k8s noded的數量。

假設虛擬機器IP資訊如下:
```
kube-ansible  10.206.30.181  MEM 4G
kube-master01 10.206.30.182  MEM 4G
kube-master02 10.206.30.183  MEM 4G
kube-node01   10.206.30.184  MEM 4G
kube-node02   10.206.30.184  MEM 4G
kube-node03   10.206.30.184  MEM 4G
```

2. ansible master主機配置
$sudo passwd root
$su -
#vi /etc/ssh/sshd_config   確保如下配置選項的開啟與關閉
    PermitRootLogin yes
    PasswordAuthentication yes
    #PasswordAuthentication no
#systemctl restart sshd
```
配置SSH Key
```
#ssh-keygen -t rsa
```
實現ansible master主機對集群其他主機root帳號的免密連接
```
#ssh-keygen    創建ssh key
#ssh-copy-id root@10.206.30.181
#ssh-copy-id root@10.206.30.182
#ssh-copy-id root@10.206.30.183
#ssh-copy-id root@10.206.30.184
#ssh-copy-id root@10.206.30.185
#ssh-copy-id root@10.206.30.186
```
安裝ansible
```
#yum install -y epel-release
#yum install -y python-pip  python-netaddr  ansible git
#pip install --upgrade Jinja2
```
在ansible master主機home目錄下git clone下載代碼，修改相關配置
```
#cd /root
#git clone https://github.com/SwarmKit/kubernetes-ansible.git
#cd kubernetes-ansible
```
根據實際虛擬機器環境修改hosts文件中的etcd、master、node主機的IP位址

編輯group_vars/all全域設定檔，確保相關位置路徑, url，k8s集群參數設置正確
```
#vi group_vars/all
```

關鍵的全域參數：

集群主機網路主介面
```
HOST_INTERFACE: eth0    
```
確保ansible master主機上的檔存儲路徑正確
```
已下載的協力廠商套裝軟體，預生成的CA證書，設定檔等目錄
CFSSL_DIR: /opt/kubernetes/data/cfssl_linux-amd64 
CA_DIR: /opt/kubernetes/data/ca
...

下載的二進位檔案執行目錄(ansible 目標主機存儲二進位檔案的位置)
BIN_DIR: /opt/kubernetes/bin
...
```
根據實際虛擬機器環境進行ip位址替換（如果使用操作3台節點組成etcd集群，請修定義相關變數和修改集群位址配置）
```

MASTER_IP: 10.206.30.188
```
為了避免每次通過網路下載二進位套裝軟體，在ansible master主機下執行playbook 02.ansible.yml,會在/opt/kubernetes/data目錄下存放下載好的安裝過程用到的二進位安裝包，在後面集群安裝用到的所有playbook中將直接通過copy模組實現檔複製，不通過get_url模組線上下載，加快構建速度
```

完成基礎安裝後需要在master或者node節點執行kubectl查看和批准命令添加集群節點，之後繼續安裝相關功能外掛程式，例如 DNS。

```