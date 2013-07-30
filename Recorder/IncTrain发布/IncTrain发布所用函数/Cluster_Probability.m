% Function to compute the Cluster Probablity
function [PC,INDEX] = Cluster_Probability(Data,Mu)%����PC��ÿ�������е�ĸ�����INDEX��ÿ�������ڵڼ�������
[No_of_Features_within_Data,No_of_Data_Points] = size(Data);%���ݺ;�ֵ���д洢
[No_of_Features_within_Mu,No_of_Mu_Points] = size(Mu);
PC(1:No_of_Mu_Points) = 0;
INDEX(1:No_of_Data_Points) = 0;
Distance(1:No_of_Data_Points,1:No_of_Mu_Points) = 0.0;

for i=1:No_of_Data_Points
    for j = 1:No_of_Mu_Points
        Distance(i,j) = sqrt(dot(Data(:,i)-Mu(:,j),Data(:,i)-Mu(:,j)));%���ݵ�i����������j�ľ���
    end
end

for i=1:No_of_Data_Points
    [value,idx] = min(Distance(i,:));
    PC(idx) = PC(idx)+1;
    INDEX(i) = idx;
end
PC = PC/No_of_Data_Points;