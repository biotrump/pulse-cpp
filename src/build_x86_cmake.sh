#!/bin/bash
#Thomas Tsai <thomas@biotrump.com>
#temp for my workspace
#BIOTRUMP_DIR=${BIOTRUMP_DIR:-master}
while [ $# -ge 1 ]; do
	case $1 in
	-debug|-d) #
		echo "\$1=-d,-debug"
		DEBUG=1
		echo "DEBUG=${DEBUG}"
		shift
		;;
	-j*)
		echo $1
		shift
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

echo "****$pulse_DIR"
echo "****$pulse_OUT"

pulse_DIR=${pulse_DIR:-`pwd`}
pulse_OUT=${pulse_OUT:-`pwd`}

if [ ! -d ${pulse_OUT} ]; then
	mkdir -p ${pulse_OUT}
else
	rm -rf ${pulse_OUT}/*
fi

pushd ${pulse_OUT}

cmake -DDEBUG=${DEBUG} -DAPP_ABI=${TARGET_ARCH}  \
${pulse_DIR}

ret=$?
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi

make ${MAKE_FLAGS}

ret=$?
popd
echo "ret=$ret"
if [ "$ret" != '0' ]; then
echo "$0 make error!!!!"
exit -1
fi
