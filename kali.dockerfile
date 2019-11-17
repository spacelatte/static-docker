#!/usr/bin/env -S docker build --compress -t pvtmert/kali -f

FROM kalilinux/kali-linux-docker

RUN apt update
RUN apt install -y kali-tools-wireless              && apt autoclean && apt clean
RUN apt install -y kali-tools-windows-resources     && apt autoclean && apt clean
RUN apt install -y kali-tools-web                   && apt autoclean && apt clean
RUN apt install -y kali-tools-vulnerability         && apt autoclean && apt clean
RUN apt install -y kali-tools-voip                  && apt autoclean && apt clean
RUN apt install -y kali-tools-top10                 && apt autoclean && apt clean
RUN apt install -y kali-tools-social-engineering    && apt autoclean && apt clean
RUN apt install -y kali-tools-sniffing-spoofing     && apt autoclean && apt clean
RUN apt install -y kali-tools-sdr                   && apt autoclean && apt clean
RUN apt install -y kali-tools-rfid                  && apt autoclean && apt clean
RUN apt install -y kali-tools-reverse-engineering   && apt autoclean && apt clean
RUN apt install -y kali-tools-reporting             && apt autoclean && apt clean
RUN apt install -y kali-tools-post-exploitation     && apt autoclean && apt clean
RUN apt install -y kali-tools-passwords             && apt autoclean && apt clean
RUN apt install -y kali-tools-information-gathering && apt autoclean && apt clean
RUN apt install -y kali-tools-headless              && apt autoclean && apt clean
RUN apt install -y kali-tools-hardware              && apt autoclean && apt clean
RUN apt install -y kali-tools-gpu                   && apt autoclean && apt clean
RUN apt install -y kali-tools-fuzzing               && apt autoclean && apt clean
RUN apt install -y kali-tools-forensics             && apt autoclean && apt clean
RUN apt install -y kali-tools-exploitation          && apt autoclean && apt clean
RUN apt install -y kali-tools-database              && apt autoclean && apt clean
RUN apt install -y kali-tools-crypto-stego          && apt autoclean && apt clean
RUN apt install -y kali-tools-bluetooth             && apt autoclean && apt clean
RUN apt install -y kali-tools-802-11                && apt autoclean && apt clean
RUN apt install -y kali-root-login                  && apt autoclean && apt clean
#RUN apt install -y kali-linux-nethunter             && apt autoclean && apt clean
#RUN apt install -y kali-linux-large                 && apt autoclean && apt clean
#RUN apt install -y kali-linux-everything            && apt autoclean && apt clean
#RUN apt install -y kali-linux-default               && apt autoclean && apt clean
#RUN apt install -y kali-linux-core                  && apt autoclean && apt clean
#RUN apt install -y kali-linux-all                   && apt autoclean && apt clean
#RUN apt install -y kali-defaults                    && apt autoclean && apt clean

RUN apt install -y \
	kali-linux-core kali-defaults

CMD su -
