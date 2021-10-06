#!/usr/bin/env -S docker build --compress -t pvtmert/vscode -f

FROM codercom/code-server:latest

USER root
RUN apt update
RUN apt install -y \
	build-essential \
	iputils-ping \
	python3-pip \
	traceroute \
	docker.io \
	net-tools \
	autoconf \
	automake \
	testdisk \
	dnsmasq \
	binwalk \
	tcpdump \
	python3 \
	locales \
	procps \
	golang \
	nodejs \
	iftop \
	iotop \
	sshfs \
	cmake \
	clang \
	lldb \
	ncdu \
	nasm \
	tree \
	curl \
	sudo \
	nano \
	htop \
	nmap \
	tmux \
	git \
	ssh \
	vim \
	man \
	gdb \
	bsdutils       \
	binutils       \
	dnsutils       \
	elfutils       \
	hfsutils       \
	diffutils      \
	dateutils      \
	coreutils      \
	cronutils      \
	mailutils      \
	moreutils      \
	findutils      \
	cifs-utils     \
	debianutils    \
	exfat-utils    \
	avahi-utils    \
	bsdmainutils   \
	airport-utils  \
	squashfs-tools \
	default-jdk-headless \
	default-mysql-client \
	--no-install-recommends

RUN echo '\n\
vscjava.vscode-java-pack\n\
ms-azuretools.vscode-docker\n\
ms-python.python\n\
ms-vscode.cpptools\n\
ms-vscode.Go\n\
\n\
42crunch.vscode-openapi\n\
adpyke.vscode-sql-formatter\n\
alexkrechik.cucumberautocomplete\n\
amazonwebservices.aws-toolkit-vscode\n\
austin.code-gnu-global\n\
aws-scripting-guy.cform\n\
bar9.stories\n\
castwide.solargraph\n\
dart-code.dart-code\n\
dart-code.dart-code\n\
dart-code.flutter\n\
dart-code.flutter\n\
dbaeumer.vscode-eslint\n\
docsmsft.docs-markdown\n\
dphans.micropython-ide-vscode\n\
eamodio.gitlens\n\
espressif.esp-idf-extension\n\
felipe.nasc-touchbar\n\
foxundermoon.shell-format\n\
github.github-vscode-theme\n\
github.vscode-pull-request-github\n\
golang.go\n\
googlecloudtools.cloudcode\n\
hashicorp.terraform\n\
hediet.vscode-drawio\n\
ivory-lab.jenkinsfile-support\n\
jayfidev.markdown-touchbar\n\
johnpapa.vscode-peacock\n\
karigari.chat\n\
kiteco.kite\n\
mads-hartmann.bash-ide-vscode\n\
mermade.openapi-lint\n\
mikestead.dotenv\n\
monokai.theme-monokai-pro-vscode\n\
ms-azuretools.vscode-docker\n\
ms-kubernetes-tools.vscode-kubernetes-tools\n\
ms-python.devicesimulatorexpress\n\
ms-python.python\n\
ms-python.vscode-pylance\n\
ms-toolsai.jupyter\n\
ms-vscode-remote.remote-containers\n\
ms-vscode-remote.remote-ssh\n\
ms-vscode-remote.remote-ssh-edit\n\
ms-vscode.hexeditor\n\
ms-vsliveshare.vsliveshare\n\
ms-vsliveshare.vsliveshare-audio\n\
ms-vsliveshare.vsliveshare-pack\n\
ms-vsonline.vsonline\n\
msjsdiag.debugger-for-chrome\n\
mtxr.sqltools\n\
pkief.material-icon-theme\n\
rebornix.ruby\n\
redhat.java\n\
redhat.vscode-knative\n\
redhat.vscode-xml\n\
redhat.vscode-yaml\n\
rogalmic.bash-debug\n\
secanis.jenkinsfile-support\n\
spmeesseman.vscode-taskexplorer\n\
technosophos.vscode-make\n\
timonwong.shellcheck\n\
visualstudioexptteam.vscodeintellicode\n\
vsciot-vscode.vscode-arduino\n\
vscjava.vscode-java-debug\n\
vscjava.vscode-java-dependency\n\
vscjava.vscode-java-pack\n\
vscjava.vscode-java-test\n\
vscjava.vscode-maven\n\
vscjava.vscode-spring-initializr\n\
wingrunr21.vscode-ruby\n\
\n\
\n' | sort -u | xargs -trn1 -- code-server --force --install-extension \
|| echo failed successfully

WORKDIR /data
ENV PASSWORD 1234
CMD [ "-vvv", "--disable-telemetry", "--bind-addr", "0.0.0.0:8000", "." ]
