#!/bin/bash


usage() {
  echo ""
  echo "Usage: `basename $0` [-l lowerbound] [-u upperbound] [-n amount] [-s server]"
  echo ""
  echo " Return 'n' amount of available tcp ports between 'lowerbound' and 'upperbound'"
  echo " The ports will be determined randomly."
  echo ""
  echo " NO PORT WILL BE CLAIMED!"
  echo ""
  echo " It might happen that between determination and use the port is taken by a different process."
  echo " When two different ports are needed use '-n 2' rather than calling the program twice."
  echo " This might result in twice the same port, where '-n 2 will return two different ports.'"
  echo ""
  echo " options:"
  echo ""
  echo "   -h            : Show this menu."
  echo ""
  echo "   -l lowerbound : lowerbound of the range in which the port(s) should lie (default 32768)."
  echo "   -u upperbound : upperbound of the range in which the port(s) should lie (default 65536)."
  echo "   -n amount     : number of results to return."
  echo "   -s server     : ip to bind the port to (default 127.0.0.1)."
  echo ""
  exit 1
}

MIN=$((`awk "BEGIN{print 2 ** 15}"`))
MAX=$((`awk "BEGIN{print 2 ** 16}"`))
LOWER=$MIN
UPPER=$MAX
AMOUNT=1
SERVER="127.0.0.1"

while getopts ":hl:u:n:s:" opt; do
  case $opt in
    h) usage
      ;;
    l) LOWER=$(($OPTARG))
      ;;
    u) UPPER=$(($OPTARG))
      ;;
    n) AMOUNT=$(($OPTARG))
      ;;
    s) SERVER="$OPTARG"
      ;;
    \?) usage
      ;;
  esac
done

if ! [[ $LOWER =~ ^[0-9]+$ ]] || ! [[ $UPPER =~ ^[0-9]+$ ]]; then
  echo ""
  >&2 echo "ERROR: Ports should be proper integers."
  usage
fi

if [[ $UPPER -gt $MAX ]] || [[ $LOWER -gt $MAX ]] || [[ $UPPER -lt $MIN ]] || [[ $LOWER -lt $MIN ]]; then
  echo ""
  >&2 echo "ERROR: Port range should be within [$MIN, $MAX]."
  usage
fi

DELTA=$(($UPPER-$LOWER))

if [[ $AMOUNT -gt $DELTA ]]; then
  echo ""
  >&2 echo "ERROR: The port range '$DELTA' is smaller than the expected result size '$AMOUNT'."
  usage
fi

if [[ $((5 * $AMOUNT)) -gt $DELTA ]]; then
  >&2 echo "WARNING: Port range is relative small to amount of wanted ports. It might not be possible to find the correct amount of ports. Increase the range, if this is the case."
fi

RESULTS=()
I=0
while [[ $I -lt $((10 * $AMOUNT)) && ${#RESULTS[@]} -lt $(($AMOUNT)) ]]; do
  PORT=$(($(($RANDOM%$DELTA))+$LOWER))
  BIND=`(echo >/dev/tcp/$SERVER/$PORT) &>/dev/null || echo "port $PORT is available"`
  if [[ ! -z "$BIND" ]] && [[ " ${RESULTS[@]} " != *" $PORT "* ]]; then
    RESULTS+=($PORT)
  fi
  I=$((I+1))
done

if [[ ${#RESULTS[@]} -lt $AMOUNT ]]; then
  >&2 "ERROR: Unable to find $AMOUNT free ports. Extend the range."
  exit 1
fi

echo ${RESULTS[@]}
