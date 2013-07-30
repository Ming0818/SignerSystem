
function [mfccc,FrameSize,framelocation,energy]=getmfcc(speechname,SpeakerName,dimension)%��ĳһ���ļ��е�ĳһ���ļ�������ȡmfcc����������mfcc����ccc,֡��sizec��
%��ȡ�����������õ�ģ��ѵ������ĵ�
%direct�ӵڼ���Ŀ¼��ȡ����
%start ��Ŀ¼�еڼ����ļ���ȡ
%filenum��ȡ�ļ���Ŀ
%snrû�õ�
%dimension��������ά��
%energy �˲�����
%framelocation ÿ������������ȡ�ĵ����
%FrameSize����ȡ�ĵ����
%mfccc��ȡ�����ĵ�
bankm=24;
addr='E:\Speechdata';
%addr='E:\34trainsample';
framelength=256;
maxfrequency=8000;
framelocation=0;
%xx=zeros(75000,256);
index=0;
xxt=zeros(700,framelength);

    [wavx ,fs ]=readspeech(speechname,SpeakerName,addr);%��Ŀ¼addr��i��Ŀ¼�ĵ�j���ļ�
    x=0.3*wavx;
    xtemp=double(x);
    xxtemp=enframe(xtemp,framelength,framelength/2);% �����źŷ�֡  ��x 256���Ϊһ֡ ���д洢
    xxtempE=xxtemp.^2;
    xxtempEn=sum(xxtempE,2);
    [xxtempEna,xxtempEnb]=size(xxtempEn);
    xxtempEm=mean(xxtempEn)/4;
    xxtempEm=repmat(xxtempEm,xxtempEna,xxtempEnb);
    xxtempEn=xxtempEn-xxtempEm;%��ʱ������
    xxtempZ=sgn(xxtemp);
    xxtempzm=mean(xxtempZ);
    [xxtempZa,xxtempZb]=size(xxtempZ);
    xxtempzm=repmat(xxtempzm,xxtempZa,xxtempZb);
    xxtempZ=xxtempZ-xxtempzm*2;%��ʱ�����ʵ�
    [xline,xrow]=size(xxtemp);
    Discard=0;
    j=1;
    while  j+Discard<xline %����ʱ�����ʸ�  ��ʱ�����͵�֡����
        if xxtempEn(j)<0 && xxtempzm(j)>0
            temp=xxtemp(j,:);
            while xxtempEn(xline-Discard)<0 && xxtempZ(xline-Discard)>0
                Discard=Discard+1;
            end
            xxtemp(j,:)=xxtemp(xline-Discard,:);
            xxtemp(xline-Discard,:)=temp;
            xteEn=xxtempEn(j);
            xxtempEn(j)=xxtempEn(xline-Discard);
            xxtempEn(xline-Discard)=xteEn;
            xtezm=xxtempZ(j);
            xxtempZ(j)=xxtempZ(xline-Discard);
            xxtempZ(xline-Discard)=xtezm;
            Discard=Discard+1;
        end
        j=j+1;
    end
    xxt((index+1):(index+xline-Discard),:)=xxtemp(1:xline-Discard,:);
    index=index+xline-Discard;
    xx=xxt(1:index,:);
%%%����mel�˲���
%%%%%%%%%%%%%%%%%%%%%%%%%%%
melhigh=1127*log(1+maxfrequency/700);
e=2.718281828459045;
each=melhigh/bankm;
eachmel=zeros(1,bankm);
eachhz=zeros(1,bankm);
for i=1:bankm
    eachmel(i)=each*i;
    eachhz(i)=700*(e^(eachmel(i)/1127)-1);
    eachhz(i)=eachhz(i)*framelength/maxfrequency;
end

hz=zeros(bankm+1);
hz(2:bankm+1)=eachhz(1:bankm);
bank=zeros(framelength,bankm);
for i=1:bankm
    for j=1:framelength
        if(j<=hz(i)&&j>hz(i-1))
            bank(j,i)=(j-hz(i-1))/(hz(i)-hz(i-1));
        end
        if(j<=hz(i+1)&&j>hz(i))
            bank(j,i)=(hz(i+1)-j)/(hz(i+1)-hz(i));
        end
        if (j>hz(i+1))
            bank(j,i)=0;
        end
    end
end
% ��һ��mel�˲�����ϵ��
[banka,bankb]=size(bank);
bank=full(bank);%24*102
bank=bank/max(bank(:));
bankS=sum(bank);
bank=bank./repmat(bankS,banka,1);
bank=bank';
[bankline,bankrow]=size(bank);
dctcoef=zeros(dimension/2,bankm);
for k=1:dimension/2
    for n=1:bankm
        dctcoef(k,n)=cos((n-0.5)*k*pi/(bankm));%ÿ��ΪһάMFCC�����Ҳ���
        if(abs(dctcoef(k,n))<0.01)
            dctcoef(k,n)=0;
        end
    end
end
% ��һ��������������
w = 1 + (dimension/4) * sin(pi * (1:dimension/2) /(dimension/2));
w = w/max(w);
FrameSize=0;
c0=zeros(size(xx,1),bankline);
m=zeros(size(xx,1),dimension/2);
%%%%%%%%%%%%%%%%%%%%%%%%%%ȥ��ƽ������mel�˲������������
for i=1:size(xx,1)% ����ÿ֡��MFCC����
    y = xx(i,:);%ȡ����һ֡
    s1=y';
    s2 = y' .* hamming(framelength);
    t1 = real(fft(s1));%���ٸ���Ҷ�任t��256*1
    t1=abs(t1);
%     t2=real(fft(s2));
%     t2=abs(t2);
    t2=abs(fft(s2));
    t2=(t2).^2;
    c0(i,:)=bank*t1(1:bankrow);
    ct2=bank*t2(1:bankrow);
    c1=dctcoef*log(ct2);
    c2 = c1.*w';
    m(i,:)=c2';
    FrameSize=FrameSize+1;
end
energy=mean(c0(1:FrameSize,:));
dtm = zeros(size(m));
for i=3:size(m,1)-2
    dtm(i,:) = -m(i+1,:) - m(i-1,:);%��ȡ1�ײ��ϵ��  %dtm(i,:) = -2*m(i-2,:) - m(i-1,:) + m(i+1,:) + 2*m(i+2,:);%��ȡ2�ײ��ϵ��
end
dtm = dtm / 2;%dtm = dtm / 10;
ccc = [m dtm];%�ϲ�mfcc������һ�ײ��mfcc����
ccc = ccc(3:size(m,1)-2,:);%ȥ����β��֡����Ϊ����֡��һ�ײ�ֲ���Ϊ0
FrameSize=FrameSize-4;
ccc=ccc';
w=ones(dimension,FrameSize);
for wi= 1:(dimension/2)
    w(wi,:)=0.3+0.7*cos(wi*pi/(dimension/2));
end
mfccc=ccc;

end

