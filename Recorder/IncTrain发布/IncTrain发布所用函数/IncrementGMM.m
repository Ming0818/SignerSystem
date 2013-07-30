function [  ] = IncrementGMM( speaker,SphName,maxtrain)
%����ѧϰ
%speaker �ڼ���˵����
%Input ��������
%No_of_Clusterÿ��ģ�;������
%Num_of_Clusterÿ����˹����ĵ����
%Iteration��������
%maxtrain����������
%alphaed,Mued,Variancesed�ɵ�Ȩ�� ��ֵ ����
%alpha_standard,Mu_standard,Variances_standard�µĲ���
%   Detailed explanation goes here
S=load('E:\Speechdata\speakerdata.mat','MU','ALPHA','VAR','No_of_speaker','SpeakerName','Num_of_Cluster','Num_of_Sample');
ALPHA=S.ALPHA;
MU=S.MU;
VAR=S.VAR;
No_of_speaker=S.No_of_speaker;
SpeakerName=S.SpeakerName;
Num_of_Cluster=S.Num_of_Cluster;
Num_of_Sample=S.Num_of_Sample;
alphaed=ALPHA(:,speaker);
Mued=MU(:,:,speaker);
Variancesed=VAR(:,:,speaker);

[dimension,d2,d3]=size(MU);
[sa,slong]=size(SpeakerName);

SpkName=SpeakerName(speaker,:);
    k=1;
    for j=1:slong
        if SpkName(j)~=' '        
            SName(k)=SpkName(j);
            k=k+1;
        end
    end
[SphNum,Sphrow]=size(SphName);
Sample=0;
for i=1:SphNum
    [mfca,FrameSize,framenum,m]=getmfcc(SphName(i,:),SName,dimension);%��i������
    if i==1
        Input=mfca;
        Sample=Sample+FrameSize;
    else
        Input=[Input,mfca];
        Sample=Sample+FrameSize;
    end
end


Plimitation=0.001;%������Сֵ
Climitation=6.5;
Covarlimit=0.1;
Iteration=0.001;
ClusterNumber=Num_of_Cluster;
Clusters=Num_of_Cluster(speaker);% ��ǰѧϰ�������
alpha=alphaed(1:Clusters);
Mu=Mued(:,1:Clusters);
Variances=Variancesed(:,1:Clusters);
ClusterNum=Num_of_Sample(1:Clusters,speaker);
alphaold=alpha;
COVAR=Variances;%%���ʼ��׼�����׼��洢
COVARold=COVAR;
%Muold=Mu;%%%%ԭ��û��
ClusterOrder=zeros(256,1);
[No_of_Feature,   No_of_Data_Point] = size(Input);
Data_Point=No_of_Data_Point;
Num_of_Sample_ori=Num_of_Sample;
alpha_ori=alphaed;
Mu_ori=Mued;
Variances_ori=Variancesed;
%%%%%%%%%����
CovSize=prod(Variances);
CovDense=ClusterNum'./CovSize;%ÿ��������ܶ�
for i=1:Clusters
    ClusterOrder(i)=i;% ÿ������ı��
end
belta=zeros(Clusters,No_of_Data_Point);
beltad=zeros(No_of_Data_Point);
beltasum=zeros(Clusters);
Limit=1;
time=0;
SqrtPi=sqrt(2*pi);
Limitold=1000;


while(Limit>Iteration&&time<maxtrain)
    time=time+1;
    Probability(1:Num_of_Cluster(speaker),   1:No_of_Data_Point) = 1.0;
    Outside=0;%�����ڵ�ǰģ�͵����������
    Other_Cluster=0;%�������ƾ���ĵ����
    Clusters=Num_of_Cluster(speaker);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%ȫЭ����
    %   for i= 1:No_of_Cluster
    %       New=(Input-repmat(Mu(:,i),1,No_of_Data_Point))'/COVAR';
    %
    %       Mah=sum(New.^2,2);%%%ֵ̫���ø���Ϊ0
    %       Mah=Mah./(sum(Mah)/No_of_Data_Point);
    %       exph=exp(-0.5*Mah');
    %       %exph=exph./max(exph);
    %       Probability(i,:)=(2*pi)^(No_of_Feature/2)/det(COVAR)*exph;%%%%���ʼ������Ϊ0
    %   end
    %    Probability=abs(Probability)./max(max(abs(Probability)));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Probability=Probabilitys(Clusters,No_of_Feature,Input(:,1:No_of_Data_Point-Outside), alpha(1:Clusters),Mu(:,1:Clusters),COVAR(:,1:Clusters));%%��
    %%%%%%%%%%E-step
    maxpro=max(max(Probability));
    if(isfinite(max(max(Probability)))==0)||(isfinite(max(alpha))==0)
        error=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    if(Clusters==1)%%����ȫ��������ͬһ����Ĵ���
        maxProbability=Probability;
    else
        maxProbability=max(Probability);
    end
    k=1;
    while k<=No_of_Data_Point-Outside %���������κξ���ĵ㵥������
        if maxProbability(k)==0
            temp=maxProbability(k);
            maxProbability(k)=maxProbability(No_of_Data_Point-Outside);
            maxProbability(No_of_Data_Point-Outside)=temp;
            Ptemp=Probability(:,k);
            Probability(:,k)=Probability(:,No_of_Data_Point-Outside);
            Probability(:,No_of_Data_Point-Outside)=Ptemp;
            Intemp=Input(:,k);
            Input(:,k)=Input(:,No_of_Data_Point-Outside);
            Input(:,No_of_Data_Point-Outside)=Intemp;
            Outside=Outside+1;
            k=k-1;
        end
        k=k+1;
    end
    
    zerocluster=0;
    for i=1:Clusters
        if alpha(i)==0
            while alpha(Clusters-zerocluster)==0
                zerocluster=zerocluster+1;
            end
            if i<=Clusters-zerocluster
                [alpha(i,1),alpha(Clusters-zerocluster,1)]=Exchange(alpha(i,1),alpha(Clusters-zerocluster,1));
                [Mu(:,i),Mu(:,Clusters-zerocluster)]=Exchange(Mu(:,i),Mu(:,Clusters-zerocluster));
                [COVAR(:,i),COVAR(:,Clusters-zerocluster)]=Exchange(COVAR(:,i),COVAR(:,Clusters-zerocluster));
                [ClusterNum(i),ClusterNum(Clusters-zerocluster)]=Exchange(ClusterNum(i),ClusterNum(Clusters-zerocluster));
                [ClusterOrder(i),ClusterOrder(Clusters-zerocluster)]=Exchange(ClusterOrder(i),ClusterOrder(Clusters-zerocluster));
                [Num_of_Sample(i,speaker),Num_of_Sample(Clusters-zerocluster,speaker)]=Exchange(Num_of_Sample(i,speaker),Num_of_Sample(Clusters-zerocluster,speaker));
                [Probability(i,:),Probability(Clusters-zerocluster,:)]=Exchange(Probability(i,:),Probability(Clusters-zerocluster,:));
                zerocluster=zerocluster+1;
            end
            i=i-1;
        end
    end
    Clusters=Clusters-zerocluster;
    if min(alpha(1:Clusters))==0||(isfinite(max(alpha))==0)
        fprintf('���������');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    [alphaa,alphab]=size(alpha);
    if alphaa==1
        alpha=alpha';%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    alp=repmat(alpha(1:Clusters,1),1,No_of_Data_Point-Outside);
    beltau=alp.*Probability(1:Clusters,1:No_of_Data_Point-Outside);
    [Pa,Pb]=max(Probability(1:Clusters,1:No_of_Data_Point-Outside));
    if(isfinite(max(max(Probability)))==0)||(isfinite(max(alpha))==0)
        fprintf('error\n');
    end
    
    tabu=tabulate(Pb);
    
    beltad=sum(beltau);
    belta=beltau./repmat(beltad,Clusters,1);
    beltasum=sum(belta(:,1:(No_of_Data_Point-Outside)),2);%��BeltasumС�ڵ���2�ľ���ȥ��,beltasum����ÿ���������ֵõĵ����
    bel=1;
    recomput=0;
    [tabua,tabub]=size(tabu);
    
    if tabua<Num_of_Cluster(speaker)
        for i=tabua+1:Num_of_Cluster(speaker)
            tabu=[tabu;[i,0,0]];
        end
    end
    tabua=Num_of_Cluster(speaker);
    while bel<=Clusters  %���������ٵľ�����ں��棬��������е���
        if tabu(bel,2)/(No_of_Data_Point-Outside)<=0.001 ||tabu(bel,2)<=2%�������������������0.3%��Ϊ���ƾ���
            if bel<=Clusters
                [ClusterOrder(bel),ClusterOrder(Clusters)]=Exchange(ClusterOrder(bel),ClusterOrder(Clusters));
                [tabu(bel,:),tabu(Clusters,:)]=Exchange(tabu(bel,:),tabu(Clusters,:));
                [Probability(bel,:),Probability(Clusters,:)]=Exchange(Probability(bel,:),Probability(Clusters,:));
                if(isfinite(max(max(Probability(1:Clusters,:))))==0)
                    Mu=Muold;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                [Pa,Pb]=max(Probability(1:Clusters,1:No_of_Data_Point-Outside));
                [alpha(bel),alpha(Clusters)]=Exchange(alpha(bel),alpha(Clusters));
                [Mu(:,bel),Mu(:,Clusters)]=Exchange(Mu(:,bel),Mu(:,Clusters));
                [COVAR(:,bel),COVAR(:,Clusters)]=Exchange(COVAR(:,bel),COVAR(:,Clusters));
                [Num_of_Sample(bel,speaker),Num_of_Sample(Clusters,speaker)]=Exchange(Num_of_Sample(bel,speaker),Num_of_Sample(Clusters,speaker));
                [ClusterNum(bel),ClusterNum(Clusters)]=Exchange(ClusterNum(bel),ClusterNum(Clusters));
                
                [Num_of_Sample_ori(bel,speaker),Num_of_Sample_ori(Clusters,speaker)]=Exchange(Num_of_Sample_ori(bel,speaker),Num_of_Sample_ori(Clusters,speaker));
                [alpha_ori(bel),alpha_ori(Clusters)]=Exchange(alpha_ori(bel),alpha_ori(Clusters));
                [Mu_ori(:,bel),Mu_ori(:,Clusters)]=Exchange(Mu_ori(:,bel),Mu_ori(:,Clusters));
                [Variances_ori(:,bel),Variances_ori(:,Clusters)]=Exchange(Variances_ori(:,bel),Variances_ori(:,Clusters));
                recomput=1;
                bel=bel-1;
                Clusters=Clusters-1;
            end
        end
        bel=bel+1;
    end
    if min(alpha(1:Clusters,1))==0
                    fprintf('���������');
    end
    if min(ClusterNum(1:Clusters))==0
        fprintf('�������Ϊ0');
    end
    [Pa,Pb]=max(Probability(:,1:No_of_Data_Point-Outside));
    tabu=tabulate(Pb);
    [tabua,tabub]=size(tabu);
    if tabua<Num_of_Cluster(speaker)
        for i=tabua+1:Num_of_Cluster(speaker)
            tabu=[tabu;[i,0,0]];
        end
    end
    if(isfinite(max(max(Probability)))==0)||(isfinite(max(alpha))==0)
        fprintf('error\n');
    end

    tabua=Num_of_Cluster(speaker);
    bel=1;
    while bel<=Num_of_Cluster(speaker)
        k=1;
        if tabu(bel,2)/(No_of_Data_Point-Outside)<=0.001 ||tabu(bel,2)<=2
            if tabu(bel,2)~=0
                while k<=No_of_Data_Point-Outside %���������ƾ���ĵ�ȥ��
                    if bel==Pb(k)
                        [Probability(:,k),Probability(:,No_of_Data_Point-Outside)]=Exchange(Probability(:,k),Probability(:,No_of_Data_Point-Outside));
                        ClusterNum(bel)=ClusterNum(bel)+1;
                        Mu(:,bel)=((ClusterNum(bel)-1)*Mu(:,bel)+Input(:,k))/ClusterNum(bel);
                        COVAR(:,bel)=((ClusterNum(bel)-1)*COVAR(:,bel).^2+(Input(:,k)-Mu(:,bel)).^2)/ClusterNum(bel);
                        COVAR(:,bel)=sqrt(COVAR(:,bel));
                        [Pb(:,k),Pb(:,No_of_Data_Point-Outside)]=Exchange(Pb(:,k),Pb(:,No_of_Data_Point-Outside));
                        [Input(:,k),Input(:,No_of_Data_Point-Outside)]=Exchange(Input(:,k),Input(:,No_of_Data_Point-Outside));
                        Outside=Outside+1;
                        Other_Cluster=Other_Cluster+1;
                        k=k-1;
                    end
                    k=k+1;
                end
            end
        end
        bel=bel+1;
    end
    if min(ClusterNum(1:Clusters))==0
        fprintf('�������Ϊ0');
    end
    
    if(isfinite(max(max(Probability)))==0)||(isfinite(max(alpha))==0)
        fprintf('error\n');
    end
    if min(sum(Probability(1:Clusters,1:(No_of_Data_Point-Outside))))==0
        errorp=sum(Probability(1:Clusters,1:(No_of_Data_Point-Outside)));
        [m1,n1]=find(errorp==0);
        fprintf('����');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    if min(alpha(1:Clusters))==0
        fprintf('���������');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    if (recomput==1)%�����޸��˾����˳�򣬽������¼���
        alpha(1:Clusters)=alpha(1:Clusters)./sum(alpha(1:Clusters));%%��ԭ���ı������¼���alpha
        ClusterNum=alpha'*(No_of_Data_Point-Outside);%%���µ�alpha����ÿ����������
        alp=repmat(alpha(1:Clusters),1,No_of_Data_Point-Outside);
        beltau=alp.*Probability(1:Clusters,1:(No_of_Data_Point-Outside));
        beltad=sum(beltau(1:Clusters,:));
        belta=beltau./repmat(beltad,Clusters,1);% matrix mismatch
        beltasum=sum(belta(:,1:(No_of_Data_Point-Outside)),2);
    end
    if min(alpha(1:Clusters,1))==0
                    fprintf('���������');
    end
    if min(ClusterNum(1:Clusters))==0
        fprintf('�������Ϊ0');
    end
    if(isfinite(max(max(Probability)))==0)||(isfinite(max(alpha))==0)
        fprintf('error\n');
    end
    if(isfinite(max(alpha))==0)
        fprintf('error\n');
    end
    if(isfinite(max(beltasum))==0)
        error=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    %%%%%%%%%%%%M-step
    Muold=Mu;
    for i= 1:Clusters%%����Mu
        Mu(:,i)=Input(:,1:No_of_Data_Point-Outside)*belta(i,1:No_of_Data_Point-Outside)'/beltasum(i);
    end
    %%%������Mu��ԭģ��Mu�ľ���
    distance=zeros(Num_of_Cluster(speaker),Num_of_Cluster(speaker));
    for i=1:Num_of_Cluster(speaker)
        for j=1:Num_of_Cluster(speaker)
            distance(i,j)=sum((Mu_ori(:,i)-Mu(:,j)).^2./(COVAR(:,i).*COVAR(:,j)));%ģ���и�����������Ͼ���
        end
    end
    [da,db]=min(distance');
    tabudb=tabulate(db);
    
    %%%%%%%%%%%%%%%%%%%������һ�ֺϲ���ʽ�����ý��ĺϲ�������Զ�������¾���
    
    
    for i= 1:Num_of_Cluster(speaker)%%��ԭ�е�Mu�ϲ�
        if i<=Clusters
            Mu(:,i)=(beltasum(i)*Mu(:,i)+Num_of_Sample_ori(i,speaker)*Mu_ori(:,i))/(beltasum(i)+Num_of_Sample_ori(i,speaker));
        else
            if min(min(Variances_ori(:,i)))~=0
                Mu(:,i)=Mu_ori(:,i);
            end
        end
    end
    COVARold=COVAR;%%%%�ġ�����Խ�Э������ټ�������
    if(isfinite(max(max(Mu)))==0)
        error=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    for i= 1:Clusters%%����COVAR
        Mu2=repmat(Mu(:,i),1,No_of_Data_Point-Outside);
        COVAR(:,i)=((Input(:,1:No_of_Data_Point-Outside)-Mu2).^2)*belta(i,1:No_of_Data_Point-Outside)'/beltasum(i);
    end
    if(min(min(COVAR))==0)
        error=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    for i= 1:Num_of_Cluster(speaker)%%��ԭ�еķ���ϲ�
        if i<=Clusters
            COVAR(:,i)=(Num_of_Sample_ori(i,speaker)*(Variances_ori(:,i).^2)+beltasum(i)*COVAR(:,i)+(Mu_ori(:,i)-Mu(:,i)).^2*Num_of_Sample_ori(i,speaker)*beltasum(i)/(Num_of_Sample_ori(i,speaker)+beltasum(i)))/(Num_of_Sample_ori(i,speaker)+beltasum(i));
        else
            if min(min(Variances_ori(:,i)))~=0
                COVAR(:,i)=Variances_ori(:,i);
            end
        end
    end
    if(min(min(COVAR))==0)
        error=1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    COVAR(:,1:Clusters)=sqrt(COVAR(:,1:Clusters));
    alphaold=alpha;
    Num_of_Sample_sum=sum(Num_of_Sample_ori(:,speaker));
    for i=1:Num_of_Cluster(speaker)%%����alpha
        if i<Clusters
            alpha(i)=(beltasum(i)+Num_of_Sample_ori(i,speaker))/(No_of_Data_Point-Outside+Num_of_Sample_sum);
        else
            alpha(i)=Num_of_Sample_ori(i,speaker)/(No_of_Data_Point-Outside+Num_of_Sample_sum);
        end
    end
    ClusterNum=alpha*(No_of_Data_Point-Outside+Num_of_Sample_sum);
    if min(alpha(1:Clusters,1))==0
                    fprintf('���������');
    end
    if min(ClusterNum(1:Clusters))==0
        fprintf('�������Ϊ0');
    end
    if(isfinite(max(alpha(1:Clusters)))==0)
        alpha=alphaold;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    alpha=alpha./sum(alpha);%%��max��Ϊ��mean
    mean_alpha=repmat(mean(alpha(1:Clusters)),Clusters,1);
    mean_covar=repmat(mean(mean(abs(COVAR(:,1:Clusters)))),No_of_Feature,Clusters);
    mean_mu=repmat(mean(mean(abs(Mu(:,1:Clusters)))),No_of_Feature,Clusters);
    alpha_new=mean((abs(alpha(1:Clusters)-alphaold(1:Clusters))+abs(alphaold(1:Clusters))+mean_alpha(1:Clusters))./(abs(alphaold(1:Clusters))+mean_alpha(1:Clusters)));
    covar_new=mean(max((abs(COVAR(:,1:Clusters)-COVARold(:,1:Clusters))+abs(COVARold(:,1:Clusters))+mean_covar(:,1:Clusters))./(abs(COVARold(:,1:Clusters))+mean_covar(:,1:Clusters))));
    mu_new=mean(max((abs(Mu(:,1:Clusters)-Muold(:,1:Clusters))+abs(Muold(:,1:Clusters))+mean_mu(:,1:Clusters))./(abs(Muold(:,1:Clusters))+mean_mu(:,1:Clusters))));
    Limit=(alpha_new+covar_new+mu_new-3)/3;%�������¾ɲ����ı仯��
    
    Limitold=Limit;
    fprintf('time=%d,         limit=%f,    UsedCluster=%d,    AllCluster=%d,  Outside=%d��  No_of_Data_Point=%d\n',time,Limit,Clusters,Num_of_Cluster(speaker),Outside,No_of_Data_Point);
    if ((Outside-Other_Cluster)/No_of_Data_Point)>0.1 &&Outside-Other_Cluster>=20 %ʣ��ĵ�������20%�������¾���
        Clusternum=2;
        stopadd=0;
        while Clusternum<=5 && stopadd==0 && Outside-Other_Cluster>=20%���������3��10����ֱ����Ӿ���ɹ�
            [IDX, Centroid] = kmeans(Input(:,No_of_Data_Point-Outside+Other_Cluster+1:No_of_Data_Point)',Clusternum);%Centroid 3*40
            %COVARadd=IncCovariance(Input(:,No_of_Data_Point-Outside+1:No_of_Data_Point),IDX,Initial_Centroid);
            CovarAdd= Cluster_Covariance(Input(:,No_of_Data_Point-Outside+Other_Cluster+1:No_of_Data_Point),IDX,Clusternum);%�����¾���ķ���
            %%%%%%%%%%%%%%%%%%%%%%�ȽϾ���Ĵ�С��ѡ��Ҫ�����ľ���COVARadd 40*3
            CovarSize=prod(CovarAdd);
            tabu=tabulate(IDX);
            CovarNum=tabu(:,2);
            CovarDense=CovarNum'./CovarSize;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [maxc,maxcov]=max(CovarDense);
            if max(CovarDense)>=min(CovDense) %����һ���µľ���
                clu=Num_of_Cluster(speaker);
                %���¾�����ӵ�ĩβ
                ClusterNums=[ClusterNum(1:clu);CovarNum(maxcov)];%CAT arguments dimensions are not consistent.
                Mu=[Mu(:,1:clu),Centroid(maxcov,:)'];
                COVAR=[COVAR(:,1:clu),CovarAdd(:,maxcov)];
                ClusterOrder(clu+1)=clu+1;
                clu=clu+1;
                ClusterNum(1:clu)=ClusterNums(1:clu);
                Clusters=Clusters+1;
                Num_of_Cluster(speaker)=Num_of_Cluster(speaker)+1;
                %���¼ӵ�ĩβ�ľ�����ŵ���Ч�������棬�������
                [ClusterNum(Clusters),ClusterNum(clu)]=Exchange(ClusterNum(Clusters),ClusterNum(clu));
                [Mu(:,Clusters),Mu(:,clu)]=Exchange(Mu(:,Clusters),Mu(:,clu));
                [COVAR(:,Clusters),COVAR(:,clu)]=Exchange(COVAR(:,Clusters),COVAR(:,clu));
                [ClusterOrder(Clusters),ClusterOrder(clu)]=Exchange(ClusterOrder(Clusters),ClusterOrder(clu));
                alpha(1:clu,1)=ClusterNum(1:clu)/sum(ClusterNum(1:clu));
                k=0;
                out=0;
                if min(ClusterNum(1:Clusters))==0
                     fprintf('�������Ϊ0');
                end
                if min(alpha(1:Clusters,1))==0
                    fprintf('���������');
                end
                st=No_of_Data_Point-Outside+Other_Cluster;
                while k<Outside-Other_Cluster
                    if(IDX(k+1)==maxcov)
                        [Input(:,st+k),Input(:,st+out)]=Exchange(Input(:,st+k),Input(:,st+out));
                        out=out+1;
                        Other_Cluster=Other_Cluster+1;
                    end
                    k=k+1;
                end
                if ((Outside-Other_Cluster)/No_of_Data_Point)<0.1
                    stopadd=1;
                end
            end
            Clusternum=Clusternum+1;
        end
    end
    if min(ClusterNum(1:Clusters))==0
        fprintf('�������Ϊ0');
    end
    if min(alpha(1:Clusters,1))==0
        fprintf('���������');
    end
    
    %Limit=alpha_new+covar_new/(No_of_Cluster)+mu_new/(No_of_Cluster)
end%While

Variances= COVAR;
fprintf('\n');
if(isfinite(max(alpha))==0)
    alpha=alphaold;
end
if(isfinite(max(max(Mu)))==0)
    Mu=Muold;
end
if(isfinite(max(max(Variances)))==0)
    Variances=COVARold;
end
%%%%%%%%%%%�ָ�����˳��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�ĵ������ˣ����治��Ҫ����ϳɡ�ÿһ��������������ԭģ���еľ��࣬�ָ�����˳���ֱ�ӷ��ر�������
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ClusterOrder,ClusterNum,alpha,Mu,COVAR]=ResetOrder(ClusterOrder,ClusterNum,alpha,Mu,COVAR);
Mu_standard=Mued;
Mu_standard(:,1:Num_of_Cluster(speaker))=Mu;
Variances_standard=Variancesed;
Variances_standard(:,1:Num_of_Cluster(speaker))=COVAR;
alpha_standard=alphaed;
alpha_standard(1:Num_of_Cluster(speaker))=alpha;
Num_of_Sample(1:Num_of_Cluster(speaker),speaker)=ClusterNum;
ClusterSum=sum(ClusterNum);
ALPHA(:,speaker)=alpha_standard';
MU(:,:,speaker)=Mu_standard;
VAR(:,:,speaker)=Variances_standard;
save('E:\Speechdata\speakerdata.mat','MU','ALPHA','VAR','No_of_speaker','SpeakerName','Num_of_Cluster','Num_of_Sample');
end



