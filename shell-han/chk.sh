#!/bin/sh
skip=44

tab='	'
nl='
'
IFS=" $tab$nl"

umask=`umask`
umask 77

gztmpdir=
trap 'res=$?
  test -n "$gztmpdir" && rm -fr "$gztmpdir"
  (exit $res); exit $res
' 0 1 2 3 5 10 13 15

if type mktemp >/dev/null 2>&1; then
  gztmpdir=`mktemp -dt`
else
  gztmpdir=/tmp/gztmp$$; mkdir $gztmpdir
fi || { (exit 127); exit 127; }

gztmp=$gztmpdir/$0
case $0 in
-* | */*'
') mkdir -p "$gztmp" && rm -r "$gztmp";;
*/*) gztmp=$gztmpdir/`basename "$0"`;;
esac || { (exit 127); exit 127; }

case `echo X | tail -n +1 2>/dev/null` in
X) tail_n=-n;;
*) tail_n=;;
esac
if tail $tail_n +$skip <"$0" | gzip -cd > "$gztmp"; then
  umask $umask
  chmod 700 "$gztmp"
  (sleep 5; rm -fr "$gztmpdir") 2>/dev/null &
  "$gztmp" ${1+"$@"}; res=$?
else
  echo >&2 "Cannot decompress $0"
  (exit 127); res=127
fi; exit $res
���Ychk-v5.sh.20170823 �<Ms�Jrw���g�zAP�dӡwi��X�HI=��� `H�4 JVW岩Tm9%���K*�T尕������_�{f�I�C���֚�H`������g�1�[ʥi+��7�<߿%��<J~<�t�j�D��C
u��{M]baAAb�u�'
�u�3mʹ=_�����#h7WD> R�<sM�/V��$e�m��iP�1(	�إ3"����E����������_H�ێM� �	;��R�!J?�w�^�n�$��۝O�%L�L3���h�I��L��%q�����r��B�
 z��>���GU�&7K�9���� M�N�pj�듗D1�b�-�T_>T�Sǘ��%=�z�f�<@ �#��gn7sn��F�A�h�>1�q4*	���"�f.d!�R�4å��2��Ad����Տ� �4���҃#BOHȘ[TzТ#Z�O(��@//�P�m�7��i����G��ϙQ�'T�"WԵ������M)�݌��Ԙh��R0=0��vDAڂ�A{��/�,I���%�D�<�*��<�;��x���6,T��<"�����P�4H=��ȇ()�C�J��(/�))�Uvv��SN�?���k�1���L18�RT�@;�Ӱ��VȫNo�[h5��җ�Xzå#�9#?3��lJ�	(�p�ȼ��X��B
�I�?�;��R�M�>�3�A�'cD�I��#�R����X3�#�Ir|����N}%����� ����OҀ�t�8��f�$6�Ų<X�RE��c���+�<|�����'K�1V�<YL�d!�XȻ�|RU��2]A鳝j�+(T+;{��}A�n����+*LCJ+�h��7~�{k�����"Q�<����d?W&)��Ȥ���-�$�$Y��<�bh�V)�T�ORP�e��N2��A(i�P(��<��Kc��ݯl*�4l(u�Z]L��N*���jɴ�&��w�L�kN���I�F�٩<�}��dҰ�dҥ�dR�wR����Z-��Ւ�]���f#ʹ`��l��j�K�Q0�4^<�d�3�%��昺e\��JrZ�m�Zv^u�����e�c//��EW��ܴGN
�IAw 	��1�J'���f�H,���yS�Mn=S�x�40��㛹m~$���s!5{��`FA!j�Z�����k��^%%P���"&�5[7�ңG�[��.2����CX#��E5��~�ӿ��O�����ÿ���������o��*k�������d�~dZL?�b��VZ����{�<��T3`\HoF���-Q�l���xm�����������o�Uz�]O���y�2�m���z����/�q�jM����sБ!Tَ�o7�'�eKI鶇o{�7K-Ħ���^��I�`�D�?� �tm){�u-�N��2O�H3���Y'O�|�_&��+�P�I���z	%��\l�{S�E�,b��pg��.���Oei�6_(vN
�V2���.\ ����S�nػ��|W&�9K�t�D��M̭�M]dN�#w������^��ܩQ�����%�d�2��n&0-4{�}a8���S�#a-Z�E?�wh�/I6uŭ� 3ʬ:�E���1�����C6�H�(X��Q+����}u� .·��\�h8��Ϙh�)f��*�g�ۯͣ�3<�b�#����7-o1�)�1
A�H.Ŕ�ޭ�G媪�����Z}РD�e�\�ȕ�e��\}RF˜L�zBV¥�����%��uR�1+s�$�	g�Pn��jZ���"���DS�>TO�2[	�Vf�Z/��B�����Bļ`��83���otZ!O���n}�(b�z���ͬ["k��#'�#��E�ŗ�� �ڶS�ܥ���s�3���AH�t���ت9@�L���qn���?�%��=�`�3"��f����������I-��6�}j�5gA���I0����)�Cc�H/�6(մ�ŭK텧��
8�q���jU��S�ҧ#�b�A��6#iQ���ӪD��0"�^z����R����(�o��sjj즖DﺎK�h��֊�P�R�v1���,n�]�ɑ�Ӯ}M�8�OD��a	��V����sӡ����
|'kLwz�AGL�����x�
�F��a��q�8�J��Ӏ��Dw�Tqn�ә�(}O���E%�����X����	���
��2�+�U0ZfƃƠ���`��gg�w\�ޞpg!��'Mѫ�����p%�ZO����vc4���%ě87Z�3C���3:��3���o>��g&����`�H�����4�kV��{8Ű�\-�Vdu��O����v�^q5�Z���y�aMfMʥeD7��;��pT��Z�&��DU�{Q����	*� P��k�X��iq",5(�D����j���3� �V��u�yA5
��	��ZN����9.����v	�MM�Р�z)M���a�r��5�1r�*�J6K�
0��qJc���r0�\_QJ�ҝ�L����x��ͷQ�?�5�V�s�|6�f��l��(}�(e���'��if���t� ��&|޻��M���*��o����l�I��+����m��XV��f>�S.���(F��*W��������uߵH�ߵp��Z�<�j�* ��bJ%�d��|����ؾ�Xu	����`��#jw��E�I]]|�i���B�Q�G���L���4�ә��0�͉f��z��C�>������V�$��� aN�2�N�nH ��e2�f	�3��$��0`NhmM�%Qf�H��d�<�PKV1� �O!�$	s��K,$�%�a;���|��?N֟h��ߦ�O��G�}�ί(G�@�R0�L��m�F3	38n����l��`e,9�d������7�������OQRrL��&���#�H�Vx�=��	��7K-n2��������n�L�=%�����p��q��~����{�^H���͚���xM�ǟm��?!�p!����X�����I��w"(J.
����w|fb�]��P��,J�75Xp�HB������X�,�5W��*悖��Ȍ� ��m��X�g�Q���q[Bj5�r�^'�̞���n�H,/�����'C0hr۲'qc_[�z�X��ʜ�
[�.��Z�(?��ϫ��o��OҰ���&��X��s1���("�yM��A|��?����l.
Q�|�"R��'��d+A��2�U,`P<!��#� ��8��  ��	�@!�Y0P_�!R%�5��|~�7OL���~K�����tS.f�t�N��6��{�wKM�W'�5��O�t긷q��A��k��<�b[�j�c��Zy�.e��4�j�\�A����ϙ��5�^�x,�xf���Z6���T<�K˫w�]~�m��_,-vKd��ψ8�ܽz��n�\��|�.�+�۠%Ϣ �j����qg)Sx�6�)�-q�,6�?o��=�ɰgyF]����\(j�'��8�ܰ���r3<ɽf���l5[q7�n5[��3,t�R��S����P��Iy[���F� ,n��;��7��#�q�"?�P,�lxg�S��y;��7�|�-�_��1X~��`+���c���"��O���$J�o �C,ݎ�n������uor>q<��ꆧ�_�ی�L�� ��cj�d�$	(v4xa�dx�(v����.#"/Vkڤ��������W��i|X{�E�;��3�k6���Z�ڼ��n�'���c<ǭk|3��1��-~rI�@Jn�9q�6�`�`:uaN��g�X�nA��."��F�p����}��v�{�U�h��8���A�ǖs�Y��H/�����ڪ�:p�x�]v4�u�i�=@(�����y)�H	���.�^�������ݯ�&�?� �X�9_{��l��*��<
��܆�JU�0g��[��G�~$ߙ�~)���I\�&������y7���|&=N(�)P�����pb#�g����P���c���;����p��y���B+����-�����wX�Db/9�f��c]:��SND�Q�KR�a�^�)H�L7�T�O�d̈́V��	�d#����]GY��n�<b��iXn��i��ق��l���35=���6�%$K�M��	j(���(���I�R8)`G�Q�=�R�9$N�nEG��(p��� �ϥ�GMy��!��ϱ%���숐�H���!C��;��Z�$t��؞�v-GG0
E���	�mk~S'�)���������;��Ҵ��}�\.$�-0I�SUg[g[���V�)"7"#GZ@��7�,�V�9�\m�)�ܚP�e��8Q[ф6q��3�`����������)�K�,[�k!�k��M������\A�bd�	<���!���'�3�i���a؈��Ejز����_�^ך��NH1������S� D�?���,��/7c/�8qb���Q����Y	��1G��g�B�� �a6?+"�t��[��{�ɕ���r���9�!�?}�l��]��;t�>�v�?B	;bd�Y�rjY*��Sm���z9�쓕c-��X��[�潦�Q�V�2+̬n�S��yW������?+��D-wow7!\����و���f�����Lй�����}��Nb�eHG~��3�X�p��dm�8�D�q���.�I"�����`��U~Qr֟ 3��`9��}���;I1���6�+Ĭ.�T����N�̥᫄����$�|��d�"�L����>&���1C���3�u­�4�u��<�x3�簱�e�l|R��(": ��Fj!��2�/^;m�~�����1;�Q �����<06E���;�\Ll��<�_nW  �4�����1�n�1�mհ���	r�dCQ�Y �ޛ���6�@DtkY��;od	�����������c>������?���� ��̻�y���?=`�X�M��Z�N���f���]���_-�{����;���ن��'��>�f3�h[yJ��?ׁ�2�7c�Q�mGf�%���͑��7� �Db����'<�#d�`&M��a�6Z�Qd!�VE���]�NV�0����.��Çd�"U������W%j<��N15Z��`C��n��Ğ2~���w1)��,�����os���2�'��!�L�����U��:2��R�TL�c۟չw���V�__C�t�k�t��0|U-h^t�-�a�]/>b�*|��;�����q��a����w��c��gD�3e<���f+��X�=�$UW.b���+�ɛ'�s�Y��k�4��g��1� ���f�� L�����A,J�� ��j�Ҳ&!�r���j�c=��i��N F�������������}��^�ROY�LAȓ~o�[�7����X^}j�<nެ�]y���6�m 	���:Z9T�	uJG���2 �
�w@ucq��K��R�wP
�nJ�n:��]P�p Ս���:�f3���`݇��K�Y&�0�5�i�E�YHg�sd.��/5K�u*�.��&D�*���Ա���cmnۆ}�&��}Y��$N�zwyx�o���s���^"�j�c{~4�m��@R�eI��x�,�4&	�  ��5wU�,���8o��aY&;�8�A�q{���U���w0(��Ġ�Ɔ/��C�q�`R�8��8�s��)p�4�lJd��eu]��7?V�+��9���ͣF���X~,��b�������%�9=�h�l��d/@vڧjŘNr���ט�(���F�}�m.O��א/o��O`?��kuXT����Y��/��}Vl`�Q�"c�!R3\ �2���hpMi�k;��̋�l��	�i������ɢ���?�ȯ!Z�O��U}̃��Kp�Kp�)�LpW�	w�(wV$���Iw���d�N*z'j�17���&��fۃ�>\��5��a`�!�Z1Ðm;��<�ob��uG�O�~~xq�$s�E�̍�%~A@/�m+�"{��&)<���)�(\���?����p�g�����3���G��$<cIx9$�哄�_��$|cI��=J�� �<����!@?� ����9��e$�9HrW%�^����(�Q�h(�r�I��E�G}�]�&S�2aQ -L�%.���虃^/�a��NX��d�kE��G*2����Q��;zA�a�k���/U�����9�n��Y:W \��^I��ǵ�͒F�T65kk���p*}��"P	s ��,t��n���d��ԏMy"D�aX%U�Eݑ�R�W�l+͏9��J�'ᷚ���"���l��N���'��]��*��Z��2��v���S.xb�=N�+`F����!&%��#�Mg���4��cKBq��l� �������;,��0⚦]�+mE�M�!p�mox���l��]�$��>l�b8J�In��&�r�
�U%E���tX%F���靜�o/p�b ��a=�:����5��z���=КY��`��3J#W)�1
}��o'5[;x���a���Zɗ�*��t ����Jhp+ێ��;�Rq\��u�mz�,2"4[�Dر��w۶�[���+��N��/2c��m�+a�>��������_�ж׽����H�d���z�5&-�A�y�/������g�Z��'�%��Pl4�+���P/K����7��8�C�b�L,8�Oû�]0�}
:S�T���/V���o���K��P�Q�IN��2�yn�P�1��ܳϘ;%��[�E�f�7�.|�]��J�5؊x��:<���(��1T���:�B�A���_(~���v�۰��P�c�=��Gň��Q)��a�U�gB�QF𩊻�s�V��ߦ"rt��籧���O�z#��j��5�
�w~2��S��d�at�|�}݀f�2�;��޽a��,  � �vt�̭}��:��C���v�D��] f��+���du ���>����N=��qH��WΩ�1�Z��W	�'��m?�xN�G��$�&{�d/Q8-;!I�bl��1��]�x��W��zok���{���s4���~M�q�}�q����h] [0��T���6��ֻ�j�E	���Q����G$���)�;Nu��Ӵ(@*/Q&�Af��q��ҙ��:�� ��Z�#ZԠ�f���h�(M_N� ����E�O�9Q��@���
x`�L0f�=� �R?��JSIK���Q\�i��i,���[l��{���� ���_���(��؈۩ 	�H����We}��X���<8F��e-.p�1Y-�(Q-��N\T�/>��?t P��.a��Y�|8q9F��T̺�5�h��V~�)��y�cڲ�������ϫTm�����
�O�&�K��T���Yvx��Z|�R�o��6�������,����'��a���O�]�z�~������@�z>�h\4N��s3�D��T����� |���1ڰ���{Hlo�1�[nzPi }\_V�[8��gN�� �D=�kd�>��#�a��X�'�]��������n˒^E�6�%.�	ݑ�e���ՉJ�֐6�KL��N��V�@QK������O�(��V��e�xEM%r����e_��B���	��!��wx�̱9��I�a�Oi��ԍ  