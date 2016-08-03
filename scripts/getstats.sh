#!/bin/bash
#
#    getstats.sh - get translation percentage of GNU web for each language 
#    Copyright (C) 2016 Rafael Fontenelle
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

die() {
    echo $1 >&2;
    exit 1
}

while getopts 'd:l:' OPTION
    do
      case $OPTION in
      d)    [ ! -d "$OPTARG" ] && die "\"$OPTARG\" não é um diretório"
            [ ! -r "$OPTARG" ] && die "\"$OPTARG\" não é legível"
            DIR="$OPTARG"
            ;;
      l)    IDIOMA="$OPTARG"
            ;;
      ?)    echo "Uso: $(basename $0) [-l IDIOMA] [-d DIR]"
            echo "Obtém estatísticas de tradução para cada idioma do site do GNU"
            echo ""
            echo " -d DIR      especifica o diretório DIR de checkout local do repositório de"
            echo "               páginas web do site do GNU; por padrão, usa o diretório atual"
            echo " -l IDIOMA   idioma para o qual você deseja obter estatísticas; por padrão,"
            echo "               retorna estatísticas de todos os idiomas reconhecidos pelo"
            echo "               arquivo \$DIR/server/gnun/languages.txt"
            echo ""
            echo "Formato da saída: classificação, idioma e porcentagem de tradução."
            echo ""
            echo "Para informações sobre como fazer checkout do repositório de páginas web do"
            echo "site do GNU, acesse o Manual do Tradutor Web GNU em:"
            echo "  <https://www.gnu.org/software/trans-coord/manual/web-trans/>"
            echo ""
            exit 2
            ;;
      esac
done



  # Se DIR não estiver definido, usa o diretório atual (pwd)
DIR=${DIR:=$(pwd)}

[ ! -f "$DIR/server/gnun/languages.txt" ] && \
    die "Diretório \"$DIR\" inválido. Veja --help para mais informações."

if [ "$IDIOMA" == "" ]; then
      # Comando extraído do email do colega Bruno Felix
      # Vide: https://lists.gnu.org/archive/html/www-pt-br-general/2015-09/msg00003.html
    for l in $(sed -e '/^#.*$/d;s/^\(^[a-z-]*[^[:space:]]\).*$/\1/' $DIR/server/gnun/languages.txt); do
     echo $l $(($(find $DIR -name "*.$l.po" | wc -l) * 100 / $(find $DIR -name '*.pot' | wc -l) + 1))%; done \
    | sort -grk2 | nl -s' ' -w2

else
      # há suporte ao idioma?
    grep $IDIOMA $DIR/server/gnun/languages.txt > /dev/null
    [ $? -eq 0 ] || die "Idioma \"$IDIOMA\" sem suporte no arquivo $DIR/server/gnun/languages.txt"

    for l in $(sed -e '/^#.*$/d;s/^\(^[a-z-]*[^[:space:]]\).*$/\1/' $DIR/server/gnun/languages.txt); do
     echo $l $(($(find $DIR -name "*.$l.po" | wc -l) * 100 / $(find $DIR -name '*.pot' | wc -l) + 1))%; done \
    | sort -grk2 | nl -s' ' -w2 \
    | grep $IDIOMA
fi

