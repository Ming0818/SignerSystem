function [ pytest] = TestSpeech( SpeechName)

S=load('E:\Speechdata\speakerdata.mat','MU','ALPHA','VAR','No_of_speaker','SpeakerName','Num_of_Cluster','Num_of_Sample');
ALPHA=S.ALPHA;
MU=S.MU;
VAR=S.VAR;
No_of_Speaker=S.No_of_speaker;
SpeakerName=S.SpeakerName;
Num_of_Cluster=S.Num_of_Cluster;
Num_of_Sample=S.Num_of_Sample;



likelihoodlimit=0.1;
bankm=24;
[speechnum,speechwidth]=size(SpeechName);
[dimension,Clustermax,MaxSpeaker]=size(MU);
[Max_Speaker,Namewidth]=size(SpeakerName);
testname='Test';
for tests=1:speechnum
    speechname=SpeechName(1,:);
    [mfc,FrameSize,framenum,m]=getmfcc(speechname,testname,dimension);
    PY=zeros(speechnum,No_of_Speaker);
    for n=1:No_of_Speaker%��ÿ�������ֱ�������Ŷȣ�
        X(:,1:FrameSize)=mfc(:,1:FrameSize);
        [No_of_Feature,No_of_Data_point]=size(X);
        pro=Probabilitys(Num_of_Cluster(n),No_of_Feature,mfc,ALPHA(:,n)',MU(:,:,n),VAR(:,:,n));
        prob=sum(pro.*repmat(ALPHA(1:Num_of_Cluster(n),n),1,No_of_Data_point));
        PX (:,n)=prob';
    end
    PX=PX./repmat(max(PX,[],2),1,No_of_Speaker);
    PXsum=zeros(FrameSize);
    PXmax=zeros(FrameSize);
    PXT=PX';
    [PXa,PXb]=size(PXT);
    if PXa==1
        PXsum=PXT;
        PXmax=PXT;
    else    
        PXsum=sum(PXT);%%����֡���Ŷ�
        PXmax=max(PXT);
    end
    

    PXF=PXmax./PXsum;%���Ŷ�
    j=0;
    for k=1:FrameSize %����Ȼ�ȵ͵�֡�ú�
        if(PXF(k)<likelihoodlimit)
            PXF(k)=0;
            Ptemp=PXT(:,FrameSize-j);
            PXT(:,FrameSize-j)=PXT(:,k);
            PXT(:,k)=Ptemp;
            j=j+1;
        end
    end
    if FrameSize-j==0
        fprintf('֡��Ȼ��̫��');
    end
    PXM=zeros(No_of_Speaker,FrameSize-j);
    PXM(:,:)=PXT(:,1:FrameSize-j);%ȥ������ʶ��
    [PXMmax,PXrow]=max(PXM);%PXMmaxΪÿ�����ֵ��PXrowΪ���ֵ���ڵ��еı�ţ���ÿ֡�ĺ�ѡ˵����
    PXtabu=tabulate(PXrow);%ͳ�Ƴ����������ĺ�ѡ˵����
    PXtwo=PXtabu(:,2);
    [PXtwomax,PXtwomaxrow]=max(PXtwo);
    [PXMa,PXMb]=size(PXM);
    if PXMa==1
        PXrow=PXM;
    end
    
    for h=1:(FrameSize-j)%��
        if(PXrow(h)~=PXtwomaxrow)
            PXM(:,h)=0;
        end
    end

    PY=sum(PXM(:,1:FrameSize-j)');
    [pymax,pyadd]=max(PY,[],2);%pymaxΪÿ�����ֵ��pyaddΪÿ�����ֵλ��
    pyspeaker=pyadd;
    
    pytest=SpeakerName(pyspeaker,:);
    
    fprintf('The  speech: "%s" test result is "%s".\n',SpeechName(tests,:),SpeakerName(pyspeaker,:));
end

end

