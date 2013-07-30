function [ ] = Training(SpkName,SphName,trainnum)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%SpeakerName ��10λ��������ַ�����ʾ��ѵ��˵���˵�����
%SphName ���д洢�Ĵ�ѵ������������ÿ�б�������ͬ�ַ��������������Կո���
addpath('E:\Speechdata');
dimension=40;%%%%%%%%%%%�˵��� ��ʱ������  ��ʱ�����ʵ͵�Ϊ������������ż��
Max_Cluster=256;
framelength=256;
confidence=0.1;
Cluster=50;%ÿ��ģ�;�����
S=load('E:\Speechdata\speakerdata.mat','MU','ALPHA','VAR','No_of_speaker','SpeakerName','Num_of_Cluster','Num_of_Sample');
ALPHA=S.ALPHA;
MU=S.MU;
VAR=S.VAR;
No_of_speaker=S.No_of_speaker;
SpeakerName=S.SpeakerName;
Num_of_Cluster=S.Num_of_Cluster;
Num_of_Sample=S.Num_of_Sample;
No_of_speaker=No_of_speaker+1;
speakeradd=No_of_speaker;
[Spka,Spkb]=size(SpkName);
SpeakerName(speakeradd,1:Spkb)=SpkName;
%��SpeakerNameȥ����
%[sa,sb]=size(SpeakerName);
% j=1;
% for i=1:Spklength
%     if SpkName(i)~=' '
%         SName(j)=SpkName(i);
%         j=j+1;
%     end
% end
[SphNum,Sphrow]=size(SphName);
Sample=0;
for i=1:SphNum
    [mfca,FrameSize,framenum,m]=getmfcc(SphName(i,:),SpkName,dimension);%��i��˵����
    if i==1
        mfc=mfca;
        Sample=Sample+FrameSize;
    else
        mfc=[mfc,mfca];
        Sample=Sample+FrameSize;
    end
end

fprintf('Add a new speaker: %s\n',SpkName);
[alpha,Mu,Variances]=GmmTraining(mfc,Cluster,0.0001,trainnum);
[alpharow,sizealpha]=size(alpha);
Num_Cluster=sizealpha;
Num_Sample=alpha*Sample;


[alphaa,alphab]=size(alpha);
Num_of_Sample(1:alphab,speakeradd)=Num_Sample';
Num_of_Cluster(speakeradd)=Num_Cluster;
ALPHA(1:alphab,speakeradd)=alpha';
MU(:,1:alphab,speakeradd)=Mu;
VAR(:,1:alphab,speakeradd)=Variances;
save('E:\Speechdata\speakerdata.mat','MU','ALPHA','VAR','No_of_speaker','SpeakerName','Num_of_Cluster','Num_of_Sample');



end

