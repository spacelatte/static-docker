#!/usr/bin/env -S docker build --compress -t pvtmert/sendmail -f

FROM debian:10

RUN apt update
RUN apt install -y \
	sendmail make m4 \
	openssl sasl2-bin \
	rsyslog bsd-mailx \
	net-tools

WORKDIR /etc/mail

RUN ( \
	echo ZGl2ZXJ0KC0xKWRubAojLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t ; \
	echo LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t ; \
	echo LS0KIyAkU2VuZG1haWw6IGRlYnByb3RvLm1jLHYgOC4xNC40IDIwMTQtMTAt ; \
	echo MDIgMTc6NTQ6MDYgY293Ym95IEV4cCAkCiMKIyBDb3B5cmlnaHQgKGMpIDE5 ; \
	echo OTgtMjAxMCBSaWNoYXJkIE5lbHNvbi4gIEFsbCBSaWdodHMgUmVzZXJ2ZWQu ; \
	echo CiMKIyBjZi9kZWJpYW4vc2VuZG1haWwubWMuICBHZW5lcmF0ZWQgZnJvbSBz ; \
	echo ZW5kbWFpbC5tYy5pbiBieSBjb25maWd1cmUuCiMKIyBzZW5kbWFpbC5tYyBw ; \
	echo cm90b3R5cGUgY29uZmlnIGZpbGUgZm9yIGJ1aWxkaW5nIFNlbmRtYWlsIDgu ; \
	echo MTQuNAojCiMgTm90ZTogdGhlIC5pbiBmaWxlIHN1cHBvcnRzIDguNy42IC0g ; \
	echo OS4wLjAsIGJ1dCB0aGUgZ2VuZXJhdGVkCiMJZmlsZSBpcyBjdXN0b21pemVk ; \
	echo IHRvIHRoZSB2ZXJzaW9uIG5vdGVkIGFib3ZlLgojCiMgVGhpcyBmaWxlIGlz ; \
	echo IHVzZWQgdG8gY29uZmlndXJlIFNlbmRtYWlsIGZvciB1c2Ugd2l0aCBEZWJp ; \
	echo YW4gc3lzdGVtcy4KIwojIElmIHlvdSBtb2RpZnkgdGhpcyBmaWxlLCB5b3Ug ; \
	echo d2lsbCBoYXZlIHRvIHJlZ2VuZXJhdGUgL2V0Yy9tYWlsL3NlbmRtYWlsLmNm ; \
	echo CiMgYnkgcnVubmluZyB0aGlzIGZpbGUgdGhyb3VnaCB0aGUgbTQgcHJlcHJv ; \
	echo Y2Vzc29yIHZpYSBvbmUgb2YgdGhlIGZvbGxvd2luZzoKIwkqIG1ha2UgICAo ; \
	echo b3IgbWFrZSAtQyAvZXRjL21haWwpCiMJKiBzZW5kbWFpbGNvbmZpZyAKIwkq ; \
	echo IG00IC9ldGMvbWFpbC9zZW5kbWFpbC5tYyA+IC9ldGMvbWFpbC9zZW5kbWFp ; \
	echo bC5jZgojIFRoZSBmaXJzdCB0d28gb3B0aW9ucyBhcmUgcHJlZmVycmVkIGFz ; \
	echo IHRoZXkgd2lsbCBhbHNvIHVwZGF0ZSBvdGhlciBmaWxlcwojIHRoYXQgZGVw ; \
	echo ZW5kIHVwb24gdGhlIGNvbnRlbnRzIG9mIHRoaXMgZmlsZS4KIwojIFRoZSBi ; \
	echo ZXN0IGRvY3VtZW50YXRpb24gZm9yIHRoaXMgLm1jIGZpbGUgaXM6CiMgL3Vz ; \
	echo ci9zaGFyZS9kb2Mvc2VuZG1haWwtZG9jL2NmLlJFQURNRS5negojCiMtLS0t ; \
	echo LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t ; \
	echo LS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQpkaXZlcnQoMClkbmwKIwoj ; \
	echo ICAgQ29weXJpZ2h0IChjKSAxOTk4LTIwMDUgUmljaGFyZCBOZWxzb24uICBB ; \
	echo bGwgUmlnaHRzIFJlc2VydmVkLgojCiMgIFRoaXMgZmlsZSBpcyB1c2VkIHRv ; \
	echo IGNvbmZpZ3VyZSBTZW5kbWFpbCBmb3IgdXNlIHdpdGggRGViaWFuIHN5c3Rl ; \
	echo bXMuCiMKZGVmaW5lKGBfVVNFX0VUQ19NQUlMXycpZG5sCmluY2x1ZGUoYC91 ; \
	echo c3Ivc2hhcmUvc2VuZG1haWwvY2YvbTQvY2YubTQnKWRubApWRVJTSU9OSUQo ; \
	echo YCRJZDogc2VuZG1haWwubWMsIHYgOC4xNC40LTggMjAxNC0xMC0wMiAxNzo1 ; \
	echo NDowNiBjb3dib3kgRXhwICQnKQpPU1RZUEUoYGRlYmlhbicpZG5sCkRPTUFJ ; \
	echo TihgZGViaWFuLW10YScpZG5sCmRubCAjIEl0ZW1zIGNvbnRyb2xsZWQgYnkg ; \
	echo L2V0Yy9tYWlsL3NlbmRtYWlsLmNvbmYgLSBETyBOT1QgVE9VQ0ggSEVSRQp1 ; \
	echo bmRlZmluZShgY29uZkhPU1RfU1RBVFVTX0RJUkVDVE9SWScpZG5sICAgICAg ; \
	echo ICAjREFFTU9OX0hPU1RTVEFUUz0KZG5sICMgSXRlbXMgY29udHJvbGxlZCBi ; \
	echo eSAvZXRjL21haWwvc2VuZG1haWwuY29uZiAtIERPIE5PVCBUT1VDSCBIRVJF ; \
	echo CmRubCAjCmRubCAjIEdlbmVyYWwgZGVmaW5lcwpkbmwgIwpkbmwgIyBTQUZF ; \
	echo X0ZJTEVfRU5WOiBbdW5kZWZpbmVkXSBJZiBzZXQsIHNlbmRtYWlsIHdpbGwg ; \
	echo ZG8gYSBjaHJvb3QoKQpkbmwgIwlpbnRvIHRoaXMgZGlyZWN0b3J5IGJlZm9y ; \
	echo ZSB3cml0aW5nIGZpbGVzLgpkbmwgIwlJZiAqYWxsKiB5b3VyIHVzZXIgYWNj ; \
	echo b3VudHMgYXJlIHVuZGVyIC9ob21lIHRoZW4gdXNlIHRoYXQKZG5sICMJaW5z ; \
	echo dGVhZCAtIGl0IHdpbGwgcHJldmVudCBhbnkgd3JpdGVzIG91dHNpZGUgb2Yg ; \
	echo L2hvbWUgIQpkbmwgIyAgIGRlZmluZShgY29uZlNBRkVfRklMRV9FTlYnLCAg ; \
	echo ICAgICAgICAgICBgJylkbmwKZG5sICMKZG5sICMgRGFlbW9uIG9wdGlvbnMg ; \
	echo LSByZXN0cmljdCB0byBzZXJ2aWNpbmcgTE9DQUxIT1NUIE9OTFkgISEhCmRu ; \
	echo bCAjIFJlbW92ZSBgLCBBZGRyPScgY2xhdXNlcyB0byByZWNlaXZlIGZyb20g ; \
	echo YW55IGludGVyZmFjZQpkbmwgIyBJZiB5b3Ugd2FudCB0byBzdXBwb3J0IElQ ; \
	echo djYsIHN3aXRjaCB0aGUgY29tbWVudGVkL3VuY29tbWVudGQgbGluZXMKZG5s ; \
	echo ICMKRkVBVFVSRShgbm9fZGVmYXVsdF9tc2EnKWRubApkbmwgREFFTU9OX09Q ; \
	echo VElPTlMoYEZhbWlseT1pbmV0NiwgTmFtZT1NVEEtdjYsIFBvcnQ9c210cCwg ; \
	echo QWRkcj06OjEnKWRubApEQUVNT05fT1BUSU9OUyhgRmFtaWx5PWluZXQsICBO ; \
	echo YW1lPU1UQS12NCwgUG9ydD1zbXRwLCBBZGRyPTAuMC4wLjAnKWRubApkbmwg ; \
	echo REFFTU9OX09QVElPTlMoYEZhbWlseT1pbmV0NiwgTmFtZT1NU1AtdjYsIFBv ; \
	echo cnQ9c3VibWlzc2lvbiwgTT1FYSwgQWRkcj06OjEnKWRubApEQUVNT05fT1BU ; \
	echo SU9OUyhgRmFtaWx5PWluZXQsICBOYW1lPU1TUC12NCwgUG9ydD1zdWJtaXNz ; \
	echo aW9uLCBNPUVhLCBBZGRyPTAuMC4wLjAnKWRubApkbmwgIwpkbmwgIyBCZSBz ; \
	echo b21ld2hhdCBhbmFsIGluIHdoYXQgd2UgYWxsb3cKZGVmaW5lKGBjb25mUFJJ ; \
	echo VkFDWV9GTEFHUycsZG5sCmBuZWVkbWFpbGhlbG8sbmVlZGV4cG5oZWxvLG5l ; \
	echo ZWR2cmZ5aGVsbyxyZXN0cmljdHFydW4scmVzdHJpY3RleHBhbmQsbm9ib2R5 ; \
	echo cmV0dXJuLGF1dGh3YXJuaW5ncycpZG5sCmRubCAjCmRubCAjIERlZmluZSBj ; \
	echo b25uZWN0aW9uIHRocm90dGxpbmcgYW5kIHdpbmRvdyBsZW5ndGgKZGVmaW5l ; \
	echo KGBjb25mQ09OTkVDVElPTl9SQVRFX1RIUk9UVExFJywgYDE1JylkbmwKZGVm ; \
	echo aW5lKGBjb25mQ09OTkVDVElPTl9SQVRFX1dJTkRPV19TSVpFJyxgMTBtJylk ; \
	echo bmwKZG5sICMKZG5sICMgRmVhdHVyZXMKZG5sICMKZG5sICMgdXNlIC9ldGMv ; \
	echo bWFpbC9sb2NhbC1ob3N0LW5hbWVzCkZFQVRVUkUoYHVzZV9jd19maWxlJylk ; \
	echo bmwKZG5sICMKZG5sICMgVGhlIGFjY2VzcyBkYiBpcyB0aGUgYmFzaXMgZm9y ; \
	echo IG1vc3Qgb2Ygc2VuZG1haWwncyBjaGVja2luZwpGRUFUVVJFKGBhY2Nlc3Nf ; \
	echo ZGInLCAsIGBza2lwJylkbmwKZG5sICMKZG5sICMgVGhlIGdyZWV0X3BhdXNl ; \
	echo IGZlYXR1cmUgc3RvcHMgc29tZSBhdXRvbWFpbCBib3RzIC0gYnV0IGNoZWNr ; \
	echo IHRoZQpkbmwgIyBwcm92aWRlZCBhY2Nlc3MgZGIgZm9yIGRldGFpbHMgb24g ; \
	echo ZXhjbHVkaW5nIGxvY2FsaG9zdHMuLi4KRkVBVFVSRShgZ3JlZXRfcGF1c2Un ; \
	echo LCBgMTAwMCcpZG5sIDEgc2Vjb25kcwpkbmwgIwpkbmwgIyBEZWxheV9jaGVj ; \
	echo a3MgYWxsb3dzIHNlbmRlcjwtPnJlY2lwaWVudCBjaGVja2luZwpGRUFUVVJF ; \
	echo KGBkZWxheV9jaGVja3MnLCBgZnJpZW5kJywgYG4nKWRubApkbmwgIwpkbmwg ; \
	echo IyBJZiB3ZSBnZXQgdG9vIG1hbnkgYmFkIHJlY2lwaWVudHMsIHNsb3cgdGhp ; \
	echo bmdzIGRvd24uLi4KZGVmaW5lKGBjb25mQkFEX1JDUFRfVEhST1RUTEUnLGAz ; \
	echo JylkbmwKZG5sICMKZG5sICMgU3RvcCBjb25uZWN0aW9ucyB0aGF0IG92ZXJm ; \
	echo bG93IG91ciBjb25jdXJyZW50IGFuZCB0aW1lIGNvbm5lY3Rpb24gcmF0ZXMK ; \
	echo RkVBVFVSRShgY29ubmNvbnRyb2wnLCBgbm9kZWxheScsIGB0ZXJtaW5hdGUn ; \
	echo KWRubApGRUFUVVJFKGByYXRlY29udHJvbCcsIGBub2RlbGF5JywgYHRlcm1p ; \
	echo bmF0ZScpZG5sCmRubCAjCmRubCAjIElmIHlvdSdyZSBvbiBhIGRpYWx1cCBs ; \
	echo aW5rLCB5b3Ugc2hvdWxkIGVuYWJsZSB0aGlzIC0gc28gc2VuZG1haWwKZG5s ; \
	echo ICMgd2lsbCBub3QgYnJpbmcgdXAgdGhlIGxpbmsgKGl0IHdpbGwgcXVldWUg ; \
	echo bWFpbCBmb3IgbGF0ZXIpCmRubCBkZWZpbmUoYGNvbmZDT05fRVhQRU5TSVZF ; \
	echo JyxgVHJ1ZScpZG5sCmRubCAjCmRubCAjIERpYWx1cC9MQU4gY29ubmVjdGlv ; \
	echo biBvdmVycmlkZXMKZG5sICMKaW5jbHVkZShgL2V0Yy9tYWlsL200L2RpYWx1 ; \
	echo cC5tNCcpZG5sCmluY2x1ZGUoYC9ldGMvbWFpbC9tNC9wcm92aWRlci5tNCcp ; \
	echo ZG5sCmRubCAjCgpkbmwgIyBNYXNxdWVyYWRpbmcgb3B0aW9ucwpkbmwgIyBN ; \
	echo QVNRVUVSQURFX0FTKGBtYXNxLmFkZHIubG9jYWwnKWRubApGRUFUVVJFKGBh ; \
	echo bGxtYXNxdWVyYWRlJylkbmwKRkVBVFVSRShgYWx3YXlzX2FkZF9kb21haW4n ; \
	echo KWRubApGRUFUVVJFKGBtYXNxdWVyYWRlX2VudmVsb3BlJylkbmwKTUFTUVVF ; \
	echo UkFERV9ET01BSU5fRklMRShgL2V0Yy9tYWlsL2RvbWFpbnMnKWRubApGRUFU ; \
	echo VVJFKGBsaW1pdGVkX21hc3F1ZXJhZGUnKWRubAoKaW5jbHVkZShgL2V0Yy9t ; \
	echo YWlsL3Rscy9zdGFydHRscy5tNCcpZG5sCmluY2x1ZGUoYC9ldGMvbWFpbC9z ; \
	echo YXNsL3Nhc2wubTQnKWRubAoKRkVBVFVSRShgdmlydHVzZXJ0YWJsZScpZG5s ; \
	echo CmRubCAjZGVmaW5lKGBjb25mRlJPTV9IRUFERVInLGBhZG1pbicpZG5sCkZF ; \
	echo QVRVUkUoYGdlbmVyaWNzdGFibGUnKWRubApHRU5FUklDU19ET01BSU4oYHRy ; \
	echo JylkbmwKR0VORVJJQ1NfRE9NQUlOX0ZJTEUoYC9ldGMvbWFpbC9nZW5lcmlj ; \
	echo cy1kb21haW5zJylkbmwKRkVBVFVSRShgZ2VuZXJpY3NfZW50aXJlX2RvbWFp ; \
	echo bicpZG5sCgpEQUVNT05fT1BUSU9OUyhgUG9ydD1zbXRwcywgTmFtZT1UTFNN ; \
	echo VEEsIE09cycpZG5sCgpkbmwgIyBEZWZhdWx0IE1haWxlciBzZXR1cApNQUlM ; \
	echo RVJfREVGSU5JVElPTlMKTUFJTEVSKGBsb2NhbCcpZG5sCk1BSUxFUihgc210 ; \
	echo cCcpZG5sCg==                                                 ; \
	) | base64 -id | tee sendmail.mc

RUN ( \
	echo ;\#localhost             ; \
	echo ;\#localhost.localdomain ; \
	) | tee -a domains generics-domains relay-domains local-host-names

RUN ( \
	echo root info ; \
	echo ;\#root info@localhost.localdomain ; \
	echo ;\#test test@localhost.localdomain ; \
	) | tee -a genericstable

RUN ( \
	echo root   ; \
	echo info   ; \
	echo test   ; \
	echo nobody ; \
	) | tee -a trusted-users

RUN ( \
	echo root info ; \
	echo ;\#test@localhost info ; \
	) | tee -a virtusertable

RUN sed -i.old 's:START=no:START=yes:g'           /etc/default/saslauthd
RUN sed -i.old "s:LOG_CMDS='No':LOG_CMDS='Yes':g" /etc/init.d/sendmail
RUN sed -i.old 's:LOG_CMDS="No":LOG_CMDS="Yes":g' /etc/mail/sendmail.conf
RUN /usr/share/sendmail/update_tls
RUN make -j$(nproc) #&& yes | sendmailconfig

CMD hostname -A \
	| tee -a domains generics-domains relay-domains local-host-names ; \
	make ; \
	service rsyslog restart    ; \
	service saslauthd restart  ; \
	service sendmail  restart  ; \
	find /var/log . -ls        ; \
	tail -fn99 /var/log/mail.* ; \
	true
