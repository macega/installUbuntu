# opção do comando date: +%T (Time)
HORAINICIAL=$(date +%T)
# Variáveis para validar o ambiente, verificando se o usuário e "root", versão do ubuntu e kernel
# opções do comando id: -u (user), opções do comando: lsb_release: -r (release), -s (short), 
# opões do comando uname: -r (kernel release), opções do comando cut: -d (delimiter), -f (fields)
# opção do carácter: | (piper) Conecta a saída padrão com a entrada padrão de outro comando
USUARIO=$(id -u)
UBUNTU=$(lsb_release -rs)
KERNEL=$(uname -r | cut -d'.' -f1,2)
# Variável do caminho do Log dos Script utilizado nesse curso (VARIÁVEL MELHORADA)
# opções do comando cut: -d (delimiter), -f (fields)
# $0 (variável de ambiente do nome do comando)
LOG="/var/log/$(echo $0 | cut -d'/' -f2)"
# Declarando as variáveis para criação da Base de Dados do ZoneMinder
USER="root"
PASSWORD="cn22250011i"
# Declarando as variáveis para o download do PPA do ZoneMinder (Link atualizado no dia 22/07/2020)
ZONEMINDER="ppa:iconnor/zoneminder-1.36"
# Verificando se o usuário é Root, Distribuição é >=18.04 e o Kernel é >=4.15 <IF MELHORADO)
# [ ] = teste de expressão, && = operador lógico AND, == comparação de string, exit 1 = A maioria dos erros comuns na execução
clear
if [ "$USUARIO" == "0" ] && [ "$UBUNTU" == "18.04" ] && [ "$KERNEL" == "4.15" ]
	then
		echo -e "O usuário é Root, continuando com o script..."
		echo -e "Distribuição é >= 18.04.x, continuando com o script..."
		echo -e "Kernel é >= 4.15, continuando com o script..."
		sleep 5
	else
		echo -e "Usuário não é Root ($USUARIO) ou Distribuição não é >=18.04.x ($UBUNTU) ou Kernel não é >=4.15 ($KERNEL)"
		echo -e "Caso você não tenha executado o script com o comando: sudo -i"
		echo -e "Execute novamente o script para verificar o ambiente."
		exit 1
fi
#
echo -e "Instalação do ZoneMinder no GNU/Linux Ubuntu Server 18.04.x\n"
echo -e "Após a instalação do ZoneMinder acessar a URL: http://`hostname -I | cut -d ' ' -f1`/zm/\n"
sleep 5
#
echo -e "Atualizando as listas do Apt, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	sudo apt update
echo -e "Listas atualizadas com sucesso!!!, continuando com o script..."
sleep 5
#
echo -e "Atualizando o sistema, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	sudo apt -y upgrade
echo -e "Sistema atualizado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Removendo software desnecessários, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	sudo apt -y autoremove
echo -e "Software removidos com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Instalando tasksel..."
    sudo apt-get install tasksel -y
sleep 5
echo
#
echo -e "Instalando lamp-server..."
    sudo tasksel install lamp-server -y
sleep 5
echo
#
echo -e "Adicionando o PPA do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando echo |: (faz a função do Enter)
	sudo add-apt-repository $ZONEMINDER -y
echo -e "PPA adicionado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "update..."
    sudo apt update
sleep 5
echo
#
echo -e "upgrade..."
    sudo apt -y upgrade
sleep 5
echo
#
echo -e "dist-upgrade..."
    sudo apt-get dist-upgrade -y
sleep 5
echo
#
echo -e "Instalando o ZoneMinder, esse processo demora um pouco, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opção do comando apt: -y (yes)
	sudo apt -y install zoneminder &>> $LOG
echo -e "ZoneMinder instalado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Alterando as permissões do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# opções do comando chmod: -v (verbose), 740 (dono=RWX,grupo=R,outro=)
	# opções do comando chown: -v (verbose), -R (recursive), root (dono), www-data (grupo)
	# opções do comando usermod: -a (append), -G (group), video (grupo), www-data (user)
	chmod -v 740 /etc/zm/zm.conf &>> $LOG
	chown -v root.www-data /etc/zm/zm.conf &>> $LOG
	chown -Rv www-data.www-data /usr/share/zoneminder/ &>> $LOG
	usermod -a -G video www-data &>> $LOG
echo -e "Permissões alteradas com sucesso com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Habilitando os recursos do Apache2 para o ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão)
	# a2enmod (Apache2 Enable Mode), a2enconf (Apache2 Enable Conf)
	a2enmod cgi &>> $LOG
	a2enmod rewrite &>> $LOG
	a2enconf zoneminder &>> $LOG
    a2enmod expires &>> $LOG
    a2enmod headers &>> $LOG
	systemctl restart apache2 &>> $LOG
echo -e "Recurso habilitado com sucesso!!!, continuando com o script..."
sleep 5
echo
#
echo -e "Criando o Serviço do ZoneMinder, aguarde..."
	# opção do comando: &>> (redirecionar a saída padrão).
	systemctl enable zoneminder &>> $LOG
	systemctl restart zoneminder &>> $LOG
    systemctl reload apache2 &>> $LOG
echo -e "Serviço criado com sucesso!, continuando com o script..."
sleep 5
echo