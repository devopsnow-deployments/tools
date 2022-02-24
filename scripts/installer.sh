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
‹     ì<Kl$Çu›O_rˆb O½½"iíg†Ÿ¥HdŠ¤´Ä.—?’ååšÓœ©™i³§{Ôİ³ähÍ 	\|Mà @r r ‹/F.:%œC A.É)1’÷^UuW÷4É]KŞ Á$ÎtÕ«WU¯Ş¿^«6ëçş©ãçŞ½%únÜ[ª›ßús«±Ø¬/--ßk./ßª7êKË‹·`éÖKøŒãÄ nÅnrêEWÃİÔÿôS›ï¹g¢â§"ŠE5¾Š$šTİ¾’—rşËúü›Í{xşËtşõWçÿsÿÜ~mşÔæãe‰Î {Î=ß‡Øb½0ºî¤V«ÛKDÛ0Š¼ pœ@2Ğ	ƒ%†°ÇÏ=Ïàêw'1ºA·ê{ 7ê‡¿j«ùlKNÕ°:nN#}Ôİòûpàg0	Ç´ñ‚¾Zßù€æÂsìÓèV–ëuëÖ«ÏÊ?K}-ÑS¯#¾@ı¿Œ}¥ü7–´ü/-7ë$ÿØøJş_ÆçñQà%O¬Mw"o”xaĞzvGñÄ°NaY$K<±9ZQ&ÖÖ…è õ’Öü8æı°ãú¬M®5)0/’Î¼î•°ÜQEUÒóúµ‰;ô­}3f×?w'1Î¿`ƒï?±>tQátß´†c?ñªc\NAû"y%î?‹üÇ"jñàÍÿk4›Kÿ¯Ù\~%ÿ/Ûşlí°½±uòh}g«UbR€÷¶nµXŠãIœˆaW}Ï;ÏL—ÚŒXÖm†OTãÄ=EkHy‡$w4ŠBô+ÜD@×‹D'	#OÄÖğŸ :‚‚‚Éë«3‚jj7éü°)TĞSVg0»ğÆ¼ˆ²³,¯išŒ6D¾Kx²F.R`Hâutº’pWÑìz1SñjX½·+ ŠË±„ÿ,ÃzV¶.\»,s§¨Ü¯„{¥–_¶ÿ7Åı_´ş¿Îÿ«/fñ_½ÙDı¿x¯^¥ÿ_Æ'v‡#_¬’vq}ÔÍä®‚}_ø~x>#¿ûšıJ ÿË¿'kô¢^>àõşßÂòÂâ¢–ÿå¥¥”ÿ…ÆÂ+ùÉşßm8x1È8ÎİĞ&ˆ]².ŒcÊ¶ì ¥ˆ…ßƒfm±Vç|4ØALy t€*!,nÔxO¥›ç%qš%ºè¹Á¿c8„¾?/èŠ‘À?”U’I¤t&}öı½‡s–µ»¿ışÉÑÎúÁƒV{<tã³6ùW	ÆŠ`6´ H½*  ä<òR¬ıx<lÙ‹È]‹÷oŞ³­Í¥–İ]®¯tzËÍÓ•zc¥×yS,ô^½·Poô–ê]Û:¸¿Ş²ëŸóc[‡;{û»»‡-çşÚÜŞ_mÍ'ÃÑ¥u„NĞÉŞ‡›-ÛÁ¿öºÉ£½#İnY¾{*ü–Éa[®mÉCkÙY4§Û00[¶m)B&	=„?·‹‘üÌŒ%£gô´[öP¾ÚXXYhÖ«M´ÇøïBc¥¹²ô¦mQv/ö>ˆóŞâ‚m	1j!é­ ¤ó?¼DğóÇcO$üËítÄ(Q@è¸Å#·#äFOÈíàg‹S‹'a÷—D¥ÓŒ„Ì9öàm˜ïŠ§óÁØ÷ƒNGµl	‡˜}ÍUå°;§ó”J,—±µ7œ‘=ÄJ)ê®D}1ê/’¨÷Öï·r«µq§:_~.Ã÷ÎËĞ1‚U¢Û˜66¹ÁÚ98ÙcšÌÎYÏŞI÷dü$zƒí4lë2óPòŒ©Wya;3ÙğZ.Œ•Êlmâ;üE’œÉrüÄ@ *›Dc¡º¡únì=_¸(Ì"ã] DlÑ¹ôdÒ¡ò;L‚ôÙXË„uÇE[}˜½ÍñÔõÁéyHP½F÷)Nr¶–6d\˜M2™š¤0ˆB*µí@R€[ğ<šT„ø\*³V¥ÛƒêÙ;q=ªüåŸÁÌ3Úè¬³¿	ówæçà™Lß;—@\>/^ÂåŒU™Ó³tS†9ÅX÷,nµ‘Ñ"óĞ¨7Û²o‚ÛËºî]]Ôü(Ö´(ï4n9MˆÏ¼Q«!>…§­xt i6.ü˜<“¤säüPí'P‡×_gÄ…k$-»¦P€FAË„iÓãp.sKJi‚Ìö#Ç)qŒÂ‘ê-=hF Î×†LÆQ Î;–qì¤`™hüöz(DH;~òEĞO-gAª¦0nÕå!Fn-6Ş\\¨/Z†É½S/oİ‘ÖL’cÕJĞyĞ'¨0Ï‚IøFPwr³éœŠúÜf‹æÛ½5$íQáÄŸpüFcA!ğsıÎüÕxûõæ” çiJ
óD£Ùª”É(!™±Ú…$šäŸò]¤»A˜LQ±Q¯·¯¥Å µ¹m4İ÷ãªBY²¿’Ÿšÿèvã$×ÌQr4rèôñ˜ŸÔîŞŒïyĞ¥ªôÚ¦›™,',w±ê¸Š¹4³0ĞuÌb ~Şƒ2	ƒG41‰2o¡i ½¢;÷£TÑ­ë[oÁÖî} Î³Ì7¼LİpÊmza hÌÁû"IÈÛ'h#tâ{hOéVØ©åğ«Zånô_ØÆpd0Dıèö…àq@OE·‹ñ·®Bâ%¾¸]ÑsÇÈqÒOMÄD¤TÔR«Õ4b?Â4bjE¶‰&0‹‹Bxx°3—ñğ³ÅRlsHÂ^¯¾ÔV¡ÔˆÎÀ}L"úèOt$£¡-hÎÁş8ˆh…‡|ç?ÇÕ*şq»]ĞËĞ7å1ù6…>ÁÑçªFPá9áTˆ`–—‰‡Fx„´·ªÌëEÃ×¯clt*zè™A¤–U˜„‡²_©l†H¬D]ıcü†GI.ÈãEHLu°1“¾X^ÎÖe[’„t-UÓáÂJEnYQŠÕXÉ),pŠª]Pµ*•
­¢ufÄ§PÇƒğœWŸBtÇ*âÈ£p8¢V<…é¢Ñ(_$ºoç’.pUC36–@÷)æõ^$‘Û¡x\2$òW`Œ£ˆ”2İ„*\©XÄ%¹•Ë&¢ŸÈÙz†æÑí²•lÉ™A}énOSyÖ=CœÒ‘ğİ—>w¥Bç|C6zèN` ÓöCŒ»Šiã’,³±•æjz¥$%›¨ß$áÂL†'SV™¢sÉ 
Çı·
UŸÂ(Ë–ù^*c™HrÌ)²‚Çxê$Š…JU©\V©Îİ}¸yÂ!Í1mÄxÏŞ?Ú:88ÙÙ\bˆÕªíhèU#9şãqú(/£âØŸ/4ñ#jüåMöÛ—V…Ğ¯ï¿O65™AÅ·^¯¢iz½ºF.Qg ÃîR<Âw¾£IÕ§F#G`òQšLwÛFlÜÍ³LOaâÿ<È»^ŸÆåñg<…|lg‡‘‘Ş¶¸õàşúu“ÄwšNY#O"‹[Ñˆy+7ÏÒ\Z.(k×sÉ–¶UŒUX­ç‚ŞJÅp#>‘×›H–—B“6®±2¢´Ée€j K+÷t$zŞj‡"ÒˆR6ØrÛèLœêÆkÉğ™4[X'Í0©Ö‰:HJ,82‹‡8;cÊ— N¨ö¯PFÂÇ hº»J¶ûö)ÚˆÀ¢{¯áÚLy8Ù
u³œT]@RÚÔˆûÆ¿ª×„@¥2ftœgø¼YDcm5‘SœÙÊü8$šÖù¨]íMª pÍ¸ipË5›?ÄÊxEnò¥í|Ü+VGnNŒç”HFqIS$š­‰rZ]^l¯1Ò<E¿ÌÿHú{«Èml±cK/,7^5Ø‚ôz‚-`/
‡ i­¶ƒ˜(G#§{»‚v¦]œAÀîƒŒPŠ˜9ä°½–òÿÉqeª±nàJ'¹Rê%ƒ:©öF®D½hp%>i®D ¹’?W~Q\Gkº†å¤y~–Ód’Ë³ÜBsšå$~Ír´ùkXÎ\+ñ›²w%üÆTü¼ü–›îù™M*Ó œçpBP8álË/~”€êwú õ6±­ñ‡·±³y²õèƒ%Æ1¥©J•Šl\ÎLéOÄÍk”[º‘!MÒš‹&mzH…óÏéœ½ìä™ºúˆäÁÅ_g<x´+m/e³"Ì8G!çvƒ±VÇ´nh?»™MFó(8\ß/ËP–!"Øi<íú¾èf4È{x¦¹€Š­•ïOáCÑ%ÚÉÜh’LÖàŒ\ájc	g.­4£Q—aÆyJ¹3™xoñİ ÇN'~ZVµ¡,pà…ßp4iDOD¼QkbŸ„±À~‘©û1çëèá÷*Û×¡XRf°e6§:@^•Y9«¢R)–<úºUY“YüêÇÅÔF0y6±*Æ*ñ	×ÓKxLEÇË¬nËrıŒ“3%ÀôÛ¦ËR¯çut½†ÃW„¶ê>,f^òi £@G¬° Çµ
Í:<xWuodáì*ô?ñFª}“jô0¢ÂxñÌí£‹¸
"‚÷Ä)4 ±²Ú\Y]zönÕ¨wÇŸÈ”EyR	ğ‡ÛM=Ûs%ĞÖQÏ¼¾ „c™á?¶kóÇvödV3˜íWİš0Ùíé1F9õÃñ\î²«’ŞvÈÜ%+dšA¤Ü½j€qu¡JU9Ùı¬Åº"›%”¸· íëÊçà“úéjh!£q1…‘‹4Å~4»]Dœ¿Òh÷CÊì 0y|Ú1ßÈ²¥Bs37¡ËvšÅôÛ‘ş¤IÜ éO<È:Â¸2Ì up	ªíNQU-¤(uÕîx8¢T—–’‡ëïn=l+á8ÖŒ°±¿½wHíò
èGdt>) C¸@rÒâú»òtĞƒ­­=²Ğüğhw÷ƒ­ı÷··Ò¶İ½}ú[†”e÷ìÇv¥8U1öÉ_iºª¥­Æls«Õ¬g-¶÷ZK++%„ôãáœ•&†ìX8SZ³äSÉ/Næ®Ô>ÙÙZ•òx±~E¼X)+fWj<ºÄ?$r"Â.¡f“‰v	®°ı5÷Wá<ÓÜ/œShXš¶6Â¯kttX^@Y}‹¼F&î‹Ú.Y^Û¡% ãlŞ^|çòdÙ’Æ“XrşI¤Ì2#¬¶±E+'S½ ëUìi3G¹]„à›÷+(9É 0ŠWœgÍÕjíòÅ(bÎ¬óÜÕ¦Zƒ¢‡ÁPäi”È<%rMêze`i¢–±eÕ1%8/Î=BX^ïDî&»F\¦{ì{ïËf´?¤¬8å[K—ß”[“ßgJ¡UczşÜ¢‰+`¿J>MCÍ¥M\Ö ºãks©Ûj!ìÈÚh`|·«ÒÅb?:ïR5RÄ4<‡PÄnÇb–µJÜ	`p¬ÂÜ{ŞRIêÜ Q0\¬ÆÀ•×1Eã‰75¹:µ(³f'µ‚4_ÛCÍ0n£vé% ¶İİ!š0Ê‰ÓEÊSpìóÖ6W<7;ÆEÅcJ¦Çãn8g›«¨–áĞ± 3C.Š<ã²PÑÃC•s+‡yÒ]–¹úd8’ò¤*ÖìÔëª9ûë6wwjí.¹oØw&w†wºwîßÙ¹s`·kÃäkhÒ'5ŸiBl„côî8¬ÄóL„á·˜nƒi’0Ë`@ê“İ½Zz–t¶Q‡´{âšr‰r™ ïI;#©ÚlÇ@/‘¥¯~”õ‘FÖ„RY¢S€LÅ‡®w04ò³–,çH1V5F€R:„jÔƒ¶r<À©·m=’¥ÀÊÕ  Fš*f"€94VŠ°ø¹M×Cç.•l©/pıw¬Êª5u-oÌ¶¹}°÷pı#é+Ë”/CÏx…wátŒ~A6Õ7Ş±
Ed>6ëü8tTXnËkV–´y(mjøyt™5u×$¯S¾q¸µ¿sĞ²yqĞÂ!½©#w	ÑÅS\UÂ]‚ÿnñß‹^G,f`şEúóœ¡§Ò‹L+»B?ìOìéš~K™Œº¹šÒšM`Jß;.¼]F†+ïÓoËq¯`ú¼•¹‚ı‘’à¢(8ukimd%‹Î‰|Ã‹¢ºÈëèîw]¿²f¥­|ÿzš¹ë4ÚÈ6ö¼ù¼,M¹òµòÊ:‡) U®Hƒb¨
9…´¡ø[àôQ]Y€rşÚüsÎP ´ñ˜V€5{º“DÕ.Ğšºf”¬ÉGÊ[¾œªH+v³¼™®C5'-á:õN~ñş×ˆá\Ÿ¼‹	¹Z1•}»§aD#†ÂÍH+M}>¸,KVŠliö²É•Ù |©)3Ó]7ŒZvudÙª¢Ñ›'[ÒÿÄq”ÉËÆå®¿¤©s¸«ÜâÍ(GC›»Ñf´±S¶‡|©Ü€,%ÕªÈÚÜİüŒ7êQ†’˜Hº–İwÛ¶ÉU[‡G{'v7îom<*¼‘w2Ÿ½XücÎTêƒÚu.¢*UfÀy(V˜Š4”‡Ü‹Â@7éxüÑ|ğğ@tIoåêZŞJ¥´d·2-e%üf¬1Ë–qN·YÊ|ŠN41CrK]·ËL½…@&€jÎÃ¨{WR¥$ÃQnŒë9ä{‘xÖ8úf<G¾Eo×Z°ÊÄßôÂ#˜‘ù¯OÖ¬ãQUßÅ A¸\4s­‘k£¥a8û¦|‘”Ï×J¢—f MXÀ_E"1ÎÔÊ|ÑKdôÓ6Ëœ³ÙÚ9ıV%=›)j©4L2@¸l±Y¿BŸ•(¸GTPp±ˆ\
á"¾´3oL®­mÃl6rïfVDær–Ùz®DòdG±(Ôî(±'¶8ÃØcYÀC‘ÊHÉƒLÎİÉ4Ö›azèÒx]Ñ†*î“ï©Hï9S´ÌáTÒ½HI™šm]cä®­šÏ›½²ˆò“pCS—K7§Bf¥‡2¬|+ÈÉŞ$B[f‡.F0·‹o˜äî¡Òp¾I­Ìæg‘UKÕı4$D«ıh”6ö±qNŞw&|ê^M²…|¥ºÈMéåÛU¤-”g”d|ØÁ»^²\p°hìMİº>=^à@ãMy7±§Ëãß=z´ùp«ÅÇh–iÜôŠÃèQ™ÜtÓ}œÌ5s¹9˜õıûÈàü?< tYšİÍAq×vè+×nærmÇxÊA¥Ù]ÛÑ?³~õîNº÷t»Ùò{)ilB¯¶°:sš7ŠdÚèìprEA»¤&_¬–]d€ó5Ó<gö¹Ä@C54ßŠÉ?~”	–”h#YŸ›ğØ>v¾~lÛ”ÌŠ[Î;kÓõBãMÑÉLöÙù¤N¥Ô·ÉîÏu™¨;„5áŒzãƒu¶*ší„]–'0ì‚T…7éïéÄC©‰&T%J‚¦´~ã»_æ—@ñ—şí{wÿ±ş•Ïşı_w?üç§ÿüÃå?úƒŸüàÓ?9úáÖoÿÂ¯üÙ>Œşî›+w×~ïÛ?úşßz¿^_j¬Ï8ÿı­¯~öÙ÷şá_şëòG?ş›ïşê¯ıä§ßzò»?ıÖèûşè¯‚¯üÇ'õw.g¾ü×ú­?şË/}íOÿü—G_ùûşÃàÓgñÓßÿÑÿg’¶îáS^1-u
W>.³uÎî’¦Ö{§~–[ÿ»«±ê¼ı»#±ìLÕÿôıªÛ'·®_Ö’`$zAê`O!_—ò´	œœ"AVßmø3–âğ:ÉÅ»èÒ‚å[
EX•¢¯ŒØX5ÍKºÛf¹ë«¢0… Ë•EÉûoG½®tz¥Ó¤ ŞüC¯³.ïÑ©÷Ë,ä+¼ª9cCÒ¦¨û9Qç#;fff·UË—77XLS?ö_é•më§&Õ=¿äg7Ü“øŸ¸¾èsÖÒ?³§›ıÛ~ğeàÁ/3jÜ¦z„e©uÜWÈñ#pÕã[Š	ëË8œüø§ëª¹³dâğm›>CfÖİËÌûƒ.=WZX³P?NóÁb¿?ËJ3wgôNIÉyt6óÜIÆUGOL9ÿ"fæO÷ÖÊƒ?gÌ	P¶xyü§Âúiy©ÓK^æÌ’~÷_è?WihUÖ¯ûŸö¼Zó¼>ğJwÎŸüŸÿìeädúíxëkïÿ6“ùó4l‡ÙùZY>±À5Ï¼’ç­óúöıíäÓëŠ¹'²2I\abk¼}«'G‚äû¬6M9ôD4Dy‰OÒ¢Ö”uyY¦mP3(7mQQİ!YÑÿòÜ-‰òİw'/0«tÒD\sÏŞ–å²Š:Í—«fÍŞ»rû{®cò¯DV*0œ>ë½Ås×ÄËj÷Ì|fF½y”v»ìs¡´ÏµëÎVïº¼;µ‡!óşnvñkûşnt»o.•z/ë_ùùßó£ÿËŸúßôîìÿxW·ÿ»ÿ*løµŸWä¬wßî­»ò¶ì<ÇP¾ğ+«¥øû.óŞmÉ1‰Òë>š´1N^ı˜ß}¯àÑ=ş£`Œ‚Q0
FÁ(£`Œ‚Q0
FÁ(£`Œ‚Q0
FÁ(£`Œ‚Q0
FÁ(£`Œ‚á	 Ad÷’ x  