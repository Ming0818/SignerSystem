#include "StdAfx.h"
#include "Users.h"
#include "ADOConn.h"

Users::Users(void)
{
	UserName="";
	PassWord="";
	
	UserId="";
	Dep="";
	Email="";
	TTA="";
	DTA="";
}

Users::Users(CString cUserName,CString cPassWord){
	this->UserName=cUserName;
	this->PassWord=cPassWord;
	
}
Users::Users(CString cUserName,CString cUserId,CString cDep,CString cEmail){
	this->UserName=cUserName;
	this->UserId=cUserId;
	this->Dep=cDep;
	this->Email=cEmail;
}

Users::~Users(void)
{
}
CString Users::getUserName(){
	return this->UserName;
}
CString Users::getPassWord(){
	return this->PassWord;
}
CString Users::getUserId(){
	return this->UserId;
}
CString Users::getDep(){
	return this->Dep;
}
CString Users::getEmail(){
	return this->Email;
}

CString Users::getTTA(){
	return this->TTA;
}
CString Users::getDTA(){
	return this->DTA;
}
void Users::setUserId(CString cUserId){
	this->UserId = cUserId;
}
void Users::setUserName(CString cUserName){
	this->UserName=cUserName;
}
void Users::setPassWord(CString cPassWord){
	this->PassWord=cPassWord;
}

void Users::setTTA(CString cTTA){
	this->TTA = cTTA;
}
void Users::setDTA(CString cDTA){
	this->DTA = cDTA;
}

BOOL Users::isExist(CString cUserName,CString cTableName){
		//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����SELECT���
	_bstr_t vSQL;
	vSQL = _T("SELECT * FROM "+cTableName+" WHERE username='" + cUserName + "'");
	
	//ִ��SELECT���
	_RecordsetPtr m_pRecordset;
	m_pRecordset = m_AdoConn.GetRecordSet(vSQL);
	if (m_pRecordset->adoEOF){
		m_AdoConn.ExitConnect();
		return false;
	}
	else{
		m_AdoConn.ExitConnect();
		return true;
	}
}

int Users::isExistId(CString cUserId,CString cTableName){
		//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����SELECT���
	_bstr_t vSQL;
	_RecordsetPtr m_pRecordset;
	
	vSQL = _T("SELECT * FROM "+cTableName+" WHERE userid='" + cUserId + "'");
	m_pRecordset = m_AdoConn.GetRecordSet(vSQL);
	if (m_pRecordset->adoEOF){
		m_AdoConn.ExitConnect();
		return 0;//���û������ڣ����أ�
	}
	
	//����Ŀ�������ţ�
	vSQL = _T("SELECT * FROM "+cTableName);
	m_pRecordset = m_AdoConn.GetRecordSet(vSQL);
	//ִ��SELECT���
	
	int count = 0;
	while (!m_pRecordset->adoEOF){
		count++;
		CString id = (LPCTSTR)(_bstr_t)m_pRecordset->GetCollect("userid");
		if(id == cUserId){
			m_AdoConn.ExitConnect();
			return count;
		}
		m_pRecordset->MoveNext();
	}

	//�Ͽ������ݿ������
	
}

BOOL Users::Insert(){
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����INSERT���
	
	_bstr_t vSQL;
	_RecordsetPtr m_pRecordset;

	vSQL = _T("INSERT INTO login(username,password) VALUES('" + this->UserName + "','" + this->PassWord + "')");	
	//ִ��INSERT���
	BOOL outcome=m_AdoConn.ExecuteSQL(vSQL);	
	//m_pRecordset->Update();
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
	return outcome;
}
BOOL Users::InsertTrainInfo(){
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����INSERT���
	
	_bstr_t vSQL;
	_RecordsetPtr m_pRecordset;
	

	vSQL = _T("INSERT INTO train(username,userid) VALUES('" + this->UserName + "','" + this->UserId +"')");	
	//ִ��INSERT���
	BOOL outcome=m_AdoConn.ExecuteSQL(vSQL);	

	//m_pRecordset->Update();
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
	return outcome;

}

BOOL Users::InsertUserInfo(){
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����INSERT���
	
	_bstr_t vSQL;
	_RecordsetPtr m_pRecordset;
	

	vSQL = _T("INSERT INTO userinfo(username,userid,department,email) VALUES('" + this->UserName + "','" + this->UserId + "','" + this->Dep + "','" + this->Email + "')");	
	//ִ��INSERT���
	BOOL outcome=m_AdoConn.ExecuteSQL(vSQL);	

	//m_pRecordset->Update();
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
	return outcome;
}

BOOL Users::InsertSignIn(){
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����INSERT���
	

	_bstr_t vSQL;
	//vSQL =_T("SELECT * FROM signin");
	//_RecordsetPtr m_pRecordset;
	//m_pRecordset = m_AdoConn.GetRecordSet(vSQL);

	vSQL = _T("INSERT INTO signin(username,userid,TimeToArrive,DateToArrive) VALUES('" + this->UserName + "','"+ this->UserId + "','"+ this->getTTA() +"','"+ this->getDTA() +"')");	
	//ִ��INSERT���
	BOOL outcome=m_AdoConn.ExecuteSQL(vSQL);

	//m_pRecordset->Update();
	//when the consequence of the SELECT is empty,
	//the Update() may have memory access error.

	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
	return outcome;
}

void Users::UpdateInfo(CString cUserName,CString cUserId,CString cDep,CString cEmail){
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����UPDATE���

	_bstr_t vSQL;
	/*
	vSQL =_T("SELECT * FROM userinfo");
	_RecordsetPtr m_pRecordset;
	m_pRecordset = m_AdoConn.GetRecordSet(vSQL);
	*/
	vSQL = _T("UPDATE userinfo SET UserName='" + cUserName + "',Department='"+ cDep +"',Email='"+ cEmail +"' WHERE UserId='" + cUserId + "'");
	//ִ��UPDATE���
	m_AdoConn.ExecuteSQL(vSQL);
	//m_pRecordset->Update();
	m_AdoConn.ExitConnect();
}

void Users::UpdatePwd(CString cUserName,CString cPassWord){
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����UPDATE���

	_bstr_t vSQL;
	vSQL = _T("UPDATE Users SET PassWord='" + cPassWord + "' WHERE UserName='" + cUserName + "'");
	//ִ��UPDATE���
	m_AdoConn.ExecuteSQL(vSQL);	
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
}

void Users::Delete(CString cUserName){
		//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����DELETE���
	_bstr_t vSQL;
	vSQL = _T("DELETE FROM login WHERE UserName='" + cUserName	+ "'");
	//ִ��DELETE���
	m_AdoConn.ExecuteSQL(vSQL);	
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
}

//����Ա����Ŷ�ȡ�����ֶ�ֵ
void Users::GetInfo(CString cUserName)
{
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����SELECT���
	_bstr_t vSQL;
	vSQL = _T("SELECT * FROM login WHERE username='" + cUserName + "'");
	//ִ��SELETE���
	_RecordsetPtr m_pRecordset;
	m_pRecordset = m_AdoConn.GetRecordSet(vSQL);

	//���ظ��е�ֵ
	if (!m_pRecordset->adoEOF)
	{
		this->UserName = cUserName;
		this->PassWord = (LPCTSTR)(_bstr_t)m_pRecordset->GetCollect("PassWord");
	}
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
}


BOOL Users::GetUserInfo(CString cUserName)
{
	//�������ݿ�
	ADOConn m_AdoConn;
	m_AdoConn.OnInitADOConn();
	//����SELECT���
	_bstr_t vSQL;
	vSQL = _T("SELECT * FROM userinfo WHERE UserName ='" + cUserName + "'");
	//ִ��SELETE���
	_RecordsetPtr m_pRecordset;
	m_pRecordset = m_AdoConn.GetRecordSet(vSQL);

	//���ظ��е�ֵ
	if (!m_pRecordset->adoEOF)
	{
		this->UserName = cUserName;
		this->UserId = (LPCTSTR)(_bstr_t)m_pRecordset->GetCollect("UserId");
		this->Dep = (LPCTSTR)(_bstr_t)m_pRecordset->GetCollect("DepartMent");
		this->Email =(LPCTSTR)(_bstr_t)m_pRecordset->GetCollect("Email");
		return TRUE;
	}
	else{
		return FALSE;
	}
	//�Ͽ������ݿ������
	m_AdoConn.ExitConnect();
}