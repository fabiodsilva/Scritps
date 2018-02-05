-bash-3.2$ cat check_ear.sh
#!/bin/bash

############## VARIAVEIS ################

LOCAL=/opt/autodeploy
#EMPRESA="SCOPUS"
EMPRESA="EXEDRA"

#### Nao alterar as variaveis abaixo ####

CHECK_EAR=$LOCAL/check_EAR
REPOS=/opt/repositorio
PACOTES=$REPOS/$EMPRESA/PACOTES
DEPLOY=$REPOS/$EMPRESA/DEPLOY
#LIST=`cat $CHECK_EAR/repos.txt`
SCRIPT_DEPLOY=$LOCAL/deploy
BACKUP=$REPOS/$EMPRESA/BACKUP
#LIST_PKT=`ls -R $REPOS | grep -i ".ear"`

ls -R $REPOS | grep -i ".ear" > earfiles.txt

LIST_PKT=`cat earfiles.txt`

if [ -s earfiles.txt ]
then

        for PKT in $LIST_PKT;
        do
                X=${PKT%.*}
                echo "t $SCRIPT_DEPLOY/$X/run.sh"

                ################################################################
                # Define no arquivo props o local onde esta o pacote ear       #
                ################################################################

                SCRIPT_PROPS=`ls $SCRIPT_DEPLOY/$X | grep props`
                SCRIPT_PROPS=$SCRIPT_DEPLOY/$X/$SCRIPT_PROPS
                echo "$SCRIPT_PROPS"
                echo "sed -i "/^cbss.app.ear.location=.*/ccbss.app.ear.location=$DEPLOY/$X/$PKT" $SCRIPT_PROPS"


                #########################
                # Executa o deploy      #
                #########################

                #cd $SCRIPT_DEPLOY/$X
                #./run.sh

                #########################
                # Gera log              #
                #########################


                echo `date "+%d/%m/%y %H:%M:%S"` Deploy da Aplicacao $X foi realizado >> $CHECK_EAR/log/log.txt

                #########################################
                # Copia o pacote aplicado para $BACKUP  #
                #########################################

                echo "mv "$REPOS/$X/$PKT" "$BACKUP/$X-ORI-`date +%d%m%y%H%M%S`.ear""

                echo "Pacote a ser aplicado copiado para $BACKUP/$X-ORI-`date +%d%m%y%H%M%S`.ear"
                echo "--------------------------------------------------------------------------------"

        done

else

        echo "nao ha pacotes"

fi
-bash-3.2$
