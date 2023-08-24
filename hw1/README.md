packer --version
1.9.2

vagrant --version
Vagrant 2.3.7

Команда для сборки образа с помощью Packer:
```
cd packer
PACKER_LOG=1 packer build centos.pkr.hcl
```

Проверка версии ядра:
vagrant up (падает этап Setting hostname, но это не мешает ВМ подняться)
vagrant ssh
uname -r
