#!/bin/bash
DATETODAY=`date +%d-%m-%Y`
#Максимальное количество копий (7 по умолчанию)
DELETEDAY=`date --date="7 days ago" +"%d-%m-%Y"`

echo "###################################TODAY IS $DATETODAY#############################"
echo "Delete OLD BACKUP day is $DELETEDAY"
SNAME=`echo $HOSTNAME`
echo "#########################This server hostname is \"$SNAME\"#############################"

#Указываем путь к сетевой шаре
SHARE="//ANDREY_ZRS-PS/My Backup's/Apelmon Backup's/2017.07.06_17.14.48.22/"
echo "Share path: $SHARE"
#Учетная запись на домене с правом подключения к данной шаре
DOMAIN=example.ru
USERNAME=backup
PASSWORD=142536
#Указываем наименование папки с БД 1с,которую необходимо зарезервировать
BACKUPBASE=ku2016
#Точка монтирования сетевой шары на данном ПК
SOURCE="/mnt/source/"
sleep 1
#Проверка наличия директории #SOURCE для монтирования сетевой шары (скрипт создает при отсутствии)
#checking $SOURCE directory exist
echo "checking $SOURCE directory exist..."
sleep 5
if ! [ -d $SOURCE ]; then
echo -e "No directory. creating $SOURCE ...\n"
sudo mkdir -p $SOURCE
sleep 1
echo "DONE!"
sleep 2
else
echo -e "Directory $SOURCE exist. Mounting $SHARE...\n"
sleep 2
fi
#Монтирование сетевой шары
#Mounting
echo "mounting CIFS share..($SHARE)"
mount -t cifs $SHARE -o username=$USERNAME,password=$PASSWORD,domain=$DOMAIN $SOURCE
sleep 2
#Путь до директории для создания резервных копий
BACKUPPATH=/mnt/backup1c/
#Проверка наличия директории $BACKUPPATH для создания резервных копий (скрипт создает при отсутствии)
#checking $BACKUPPATH directory exist
echo "checking $BACKUPPATH directory exist..."
sleep 5
if ! [ -d $BACKUPPATH ]; then
echo -e "No directory. creating $BACKUPPATH ...\n"
sudo mkdir -p $BACKUPPATH
sleep 1
echo "DONE!"
sleep 2
else
echo -e "Directory $BACKUPPATH exist. Start backuping...\n"
sleep 2
fi
#create log file 4today
#Создаем лог-файл с наименованием текущей даты
touch $BACKUPPATH$DATETODAY.log
ls $BACKUPPATH
#Удаляем файл старше максимально допустимого количества хранимых копий
echo "Deleting OLD backup folder: $DELETEDAY..."
rm -rf $BACKUPPATH$DELETEDAY.*
echo "Deleted!"
sleep 2
#Смотрим содержимое директории резервных копий после очистки устаревших данных
echo "now in $BACKUPPATH located: "
ls $BACKUPPATH
sleep 1
echo "`date +%d-%m-%Y-%H:%M` Backuping $BACKUPBASE DBs 1C to $BACKUPPATH, please wait..."
echo "Backuping started at `date +%d-%m-%Y-%H:%M`\n" >> $BACKUPPATH$DATETODAY.log
#Запускаем резервное копирование с логированием в одноименный лог-файл
sudo 7z a -mx9 $BACKUPPATH$DATETODAY.7z $SOURCE$BACKUPBASE  >> $BACKUPPATH$DATETODAY.log
#где -mx9 -ультра сжатие, для стандартного сжатия (с минимальной потерей времени), достаточно убрать данный параметр
#Основные параметры архивирования можно посмотреть тут: http://help.ubuntu.ru/wiki/7zip
echo "Backuping is DONE at `date +%d-%m-%Y-%H:%M`" >> $BACKUPPATH$DATETODAY.log
echo "`date +%d-%m-%Y-%H:%M` Backuping is done!"
sleep 1
#Отключаем сетевую шару (размонтируем)
echo "unmount mount point: ($SOURCE)"
umount $SOURCE
sleep 1
echo "All jobs is done..."
sleep 1