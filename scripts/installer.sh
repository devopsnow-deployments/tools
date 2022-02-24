#!/bin/sh
# This script was generated using Makeself 2.4.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="2750843452"
MD5="58501f65c35890dc64a3c27f2fb386f3"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"; export USER_PWD

label="OpsVerse Agent Installer"
script="./setup.sh"
scriptargs=""
licensetxt=""
helpheader=''
targetdir="makeself-142668-20220223183434"
filesizes="6548"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    echo "$licensetxt" | more
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
    { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
      test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd $@
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet		Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script
  --keep                Do not erase target directory after running
			the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the extracted files to the current user
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n 587 "$1" | wc -c | tr -d " "`
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				else
					test x"$verb" = xy && MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" = x"$crc"; then
				test x"$verb" = xy && MS_Printf " CRC checksums are OK." >&2
			else
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2;
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=y
verbose=n

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 36 KB
	echo Compression: gzip
	echo Date of packaging: Wed Feb 23 18:34:34 PST 2022
	echo Built with Makeself version 2.4.0 on 
	echo Build command was: "/usr/bin/makeself \\
    \"./\" \\
    \"installer.sh\" \\
    \"OpsVerse Agent Installer\" \\
    \"./setup.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
	echo archdirname=\"makeself-142668-20220223183434\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5\"
	echo OLDUSIZE=36
	echo OLDSKIP=588
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n 587 "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n 587 "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | eval "gzip -cd" | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
	shift
	;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -title "$label" -e "$0" --xwin "$initargs"
                else
                    exec $XTERM -title "$label" -e "./$0" --xwin "$initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n 587 "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 36 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
	MS_Printf "Uncompressing $label"
	
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = xy; then
	    echo
	fi
fi
res=3
if test x"$keep" = xn; then
    trap 'echo Signal caught, cleaning up >&2; cd $TMPROOT; /bin/rm -rf "$tmpdir"; eval $finish; exit 15' 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 36; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (36 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | eval "gzip -cd" | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi
if test x"$keep" = xn; then
    cd "$TMPROOT"
    /bin/rm -rf "$tmpdir"
fi
eval $finish; exit $res
�     �<Kl$�u��O_r�b O��"i�g���H�d����.�?���Ӝ��i��{�ݳ�h� 	�\|M� @r r��/F.:%�C A.�)1��^UuW�4�]K� ��$�tիWU�޿^�6������޽%�n�[����s��ج/--�k./ߪ7�Kˋ�`��K���č n�nr�EW�����S��g���"�E5��$�Tݾ��r������{x��t��W��s��~m����e�� {�=߇�b�0��V���KD�0�� �p�@2�	�%����=���w'1�A��{� 7ꏇ�j��lKNհ:nN#}����p�g0	Ǵ�Z�����s���V��u�֫��?K}-�S�#�@���}��7���/-7�$���J�_���Q�%O�Mw"o�xa�zvG���NaY�$K<���9ZQ&�օ� ����8�������M�5)0/�μ�QEU�����;��}3f�?w'1ο`��?�>tQ�tߝ��c?�c\NA�"y%�?���"�j����k4�K���\~%�/��l����u�h}g�UbR���n�X��I��aW}�;�L�ڌX�m�OT��=Ek�Hy�$w4�B�+�D@׋D'	#O�����:������3�jj7����)T�SVg0�������,��i��6D�Kx�F.R`H�ut��pW��z1S�jX��+ �˱��,�z�V�.\�,s��ܯ�{��_��7��_������/f�_��D��x�^��_�'v�#_��vq}�����}_�~x>#����J �˿'k��^>�������⢖�奥�����+����m8x1�8���&�]�.�cʶ젥��߃fm�V�|4�ALy t�*!,n�xO���%q�%�����c8��?/芑�?�U�I�t&�}����s������������V{<t�6�W	Ɗ`6� H�*  �<�R����x<lً�]��o޳��ͥ��]��tz��ӕzc��yS,��^��Po���]�:��޲��c[�;{����-�����_m�'�ѥu�N��އ�-�����ɣ�#�nY�{*�����a[�m�Ck�Y4��00�[�m)B&	=�?����̌%�g��[�P��XXYh֫M����Bc�����mQv/�>����m�	1j!� ��?��D���cO$���t�(Q@踞�#�#��FO���g�S�'�a��D�ӝ���9��m�������NG�l	��}�U小;��J,���7��=�J)�D}1�/�����r���q�:_~.�����1�U�ۘ�66���98�c���Y��I�d�$z��4l�2�P��Wya;3��Z.���lm�;�E���r��@ *��Dc�����n�=_�(�"�] Dlѹ�dҡ�;L���X˄u�E�[}��������y�HP�F�)Nr��6d\�M2���0�B*��@R�[��<�T��\*�V�ۃ��;q=��垟��3�謳�	�w����L�;�@\�>/^��U�ӳtS�9�X�,n���"�Ш7۲o��˺�]]��(ִ(�4n9M�ϼQ�!>���xt�i6.��<��s��P�'P��_g���k$-��P�FA˄i��p.sKJi���#�)q��-=hF ���L�Q �;�q�`�h��z(DH;~�E�O-gA��0n��!�Fn-6�\\�/Z�ɽS/oݑ�L��c�J�y�'�0��I�FPwr�霊��ܝf����5$�Q�ğp�FcA!�s����x��攠�iJ
�D�٪��(!��څ$���]��A��LQ�Q����� ��m4���BY�������v�$��Qr4r�����ތ�yХ��ڦ��,',w�긊�4�0�u�b�~ރ2	�G�41�2o�i ���;��T�ѭ�[o���}�γ�7�L�p�mza�h���"I��'h#t�{h�O�Vة��Z�n�_��pd0D�����q@OE�����B�%��]�s��q�OM�D�T�R��4b?�4bjE��&0��Bxx�3�����RlsH�^���V������}L"��Ot$��-h���8�h��|�?���*�q�]����7�1�6��>�����FP�9�T�`����Fx������E�ׯclt*z�A��U����_�l�H�D]�c��GI.��EHLu�1��X^��e[���t-�U���JEnYQ��X�),p��]P�*�
��ufħPǃ�W�Bt�*�ȣ�p8�V<���(_$�o��.pUC��36�@�)���^$�ۡx\2$�W`����2݄*\��X�%���&�����z����ləA}�nOSy�=�C������>w�B�|C6z�N` ��C���i�,����jz�$%���$��L�'SV��s� 
���
U��(˖�^*c�Hr��)���x�$��JU�\V���}�y�!��1�m�x��?�:88��\b�ժ�h�U#9��q�(/��؟/4�#j��M�ۗV�Я�O65�Aŷ^��iz��F.Qg ��R<�w��IէF#G`�Q�LwێFl�ͳLOa��<Ȼ^����g�<�|lg���޶�����u��w�NY#O"�[шy+7��\Z.�(k�sɖ�U�UX���J�p#>�כH��B�6��2���e�j K+�t$zށj�"҈R6�r��L���k��4[X'�0�։:HJ,82��8;cʗ N����PF�� h��J���)ڈ��{���Ly8ِ
u��T]@R�Ԉ�ƿ�ׄ@�2ft�g��YDcm5�S����8$����]��M��p͸ip�5��?��xEn���|�+�VGnN��HFqIS$���rZ]^l�1�<E���H�{��ml�c�K/,7^5؂�z�-`/
� i����(G#�{��v�]�A�P��9�䰽����qe��n�J'�R�%�:��F�D�hp%>i�D���?W~Q\Gk���y~��d�˳�Bs��$~�r��kX�\+�w%��T��������M*Ӡ��pBP8�l�/~���w� �6�������y���%Ɓ1��J��l\�L�O��k�[��!MҚ��&mzH�������䙺�����_g<x�+m/e�"�8G!�v��VǴ�nh?��MF�(8\�/�P�!"�i<����f4�{x�������O�C�%���h�L���\�jc	g.�4��Q�a��yJ�3�xo�� �N'~�ZV��,p��ߝp4iDOD�Qkb����~���1�����*�סXRf�e6�:@^�Y�9��R)�<��UY�Y�����F0y6�*�*�	��KxLE���n�r���3%��ۦ�R��ut���W���>,f�^�i��@G���ǵ
�:<xWuod��*�?�F�}�j�0��x����
"���)4����\Y]z��nըwǞ�ȔEyR	���M=�s%��Qϼ���c��?�k��v�dV3��Wݝ�0���1F9���\��v��%+d�A�ܽj�qu�JU9���ź"��%��� ��������j�h!�q1����4�~4�]D����h�C��0y|�1�Ȳ�Bs37��v���ۑ��I� �O<�:¸2� up	��NQU-�(u��x8�T������n=l+�8֌����wH��
�Gd�t>) C�@r�����tЃ��=����hw�������Ҷ�ݝ�}�[��e���v�8U1��_i�����ls�լg-��ZK++%���᜕&��X�8SZ��S�/N��>��Z��x�~E�X)+fWj<��?$r"�.�f��v�	���5�W�<��/�ShX��6¯kttX^@Y}��F&��.Y^ۡ%��l�^|��d��Ǝ�Xr�I��2#���E+'S���U�i3G�]����+(9� 0�W�g��j���(�bά��զZ����P�i��<%rM�ze`i���e�1%8/�=BX^�D�&�F\�{�{��f�?��8�[K�ߔ[��gJ�Ucz�ܢ�+`�J>MCͥM\� ��ks�ہj!���h`|����b?:�R5R�4<�P�n�b��J�	`p���{�RI�ܠ�Q0\�����1E�75�:�(�f'��4_�C�0n�v�%����!�0ʉ�E�Sp���6W<7;�E�cJ���n8g�����б�3C.�<��P��C�s+�y�]���d8��*����9��6wwj�.��o�w&w�w�w��ٹs`�k���kh�'5�iBl�c��8���L�ᷘn�i��0�`@꓍ݽ�Zz�t��Q���{��r�r���I;#��l�@/���~���FքRY�S�LŇ�w04�,�H1V5F�R:�jԃ�r<���m=����ՠ�F�*f"�94V����M�C�.�l�/p�w�ʪ5u-o̶�}��p�#�+�˔/C�x�w�t�~A6�7ޱ
Ed�>6��8tTXn�kV��y(mj�yt�5u�$�S�q���sвyq��!��#w	��S\U�]��n�ߋ^G,f`�E�����ҋL+�B?�O��~K�����ҚM`J�;.�]F�+��o�q�`���������(8ukimd%��Ή|Ë������w]��f��|�z���4��6������,M����:�) U�H�b�
9����[��Q]Y�r���s�P���V�5{��D�.К�f���G�[���H+v����C5'-�:�N~��׈�\���	�Z1�}��aD#���H+M}>�,KV��li��ɕ� |�)3�]7�Zvud٪�ћ'[���q����宿��s�����(GC���f��S���|��܀,%ժ�ڎ����7�Q���H����w۶�U[�G{'�v7�om<�*��w2���X�c�T��u.�*Uf�y(V��4��܋@7�x��|��@tIo��Z�J��d�2-e%�f�1˖q�N�Y�|�N41Cr�K]��L��@&�j�è{WR�$�Qn��9�{�xց8�f<G�Eo�Z�������#����O֬�QU�� A�\4s��k��a8��|����J��f�MX�_E"1���|�Kd��6˜���9�V%=��)j�4L2@�l�Y�B��(�GTPp��\
�"��3oL��m�l6r��fVD�r��z�D�dG�(��(�'�8�؞cY�C��HɃL���4֛az��x]�ц*��H�9S���T��HI��m]c䮭�ϛ����pCS�K7�Bf���2�|+���$B[f�.F0���o����p��I���g�UK��4$D����h�6��qN�w&|�^M��|���M���U�-�g�d|���^�\p�h�Mݺ>=^�@�My�7�����=z��p���h�i����Q��t�}��5s�9��������?<�tY���Aq�v�+�n�rm�x�A��]��?�~��N��t���{)ilB���:s�7�d���prEA���&_��]d��5�<g���@C54ߊ�?~�	��h#Y����>v�~l۔̊[�;k��B�M��L����N�Է���u��;�5�z�u�*��]��'0�T�7����C��&T%J���~�_�@���{�w�������_w?������?������?9���o�¯��>���+w�~��?���z�^_j��8����~�����_���G?��������z�?�����诂���'�w.g��ם��?��/}�O���G_������g����я�g����S^1-u
W>.�u��{�~�[�������#��L�������'��_֒`$zA�`O!_��	��"AV�m�3���:�Ż�҂��[
EX�����X5�K��f�뫢0� ˕E��oG���tz�Ӥ ��C��.�ѩ��,�+��9cCҦ��9Q�#;fff�U˗77XLS?�_�m�&�=��g7ܓ�����s��?�����~�e��/3jܦz�e�u�W��#p��[�	��8��������d��m�>Cf������.=WZX�P�?N��b�?�J3wg�NI�yt6��I�UGOL9�"f�O��ʃ?g�	P�xy����iy��K^�̒~�_�?WihU֯����Z�>�JwΟ����e�d��x�k��6���4l���ZY>��5ϼ������������'��2I\abk�}�'G����6M9�D4Dy�OҢ֔uyY�mP3(7mQQ�!Y����-���w'/0��t�D\s�ޖ���:͗�f�޻r�{�c�DV*0�>��s����j��|fF�y�v��s��ϵ��V��;��!���nv�k��nt�o.�z/�_�����˟������xW����*l���W�w���<�P��+����.��m�1���>��1N�^���}����=��`��Q0
F�(�`��Q0
F�(�`��Q0
F�(�`��Q0
F�(�`���	 Ad�� x  