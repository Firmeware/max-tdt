
#ifndef _RTL8192C_EVENT_H_
#define _RTL8192C_EVENT_H_

struct C2HEvent_Header
{

#ifdef CONFIG_LITTLE_ENDIAN

	unsigned int len:16;
	unsigned int ID:8;
	unsigned int seq:8;
	
#elif defined(CONFIG_BIG_ENDIAN)

	unsigned int seq:8;
	unsigned int ID:8;
	unsigned int len:16;
	
#else

#  error "Must be LITTLE or BIG Endian"

#endif

	unsigned int rsvd;

};

void dummy_event_callback(_adapter *adapter , u8 *pbuf);
void fwdbg_event_callback(_adapter *adapter , u8 *pbuf);

enum rtl8192c_c2h_event
{
	GEN_EVT_CODE(_Read_MACREG)=0, /*0*/
	GEN_EVT_CODE(_Read_BBREG),
 	GEN_EVT_CODE(_Read_RFREG),
 	GEN_EVT_CODE(_Read_EEPROM),
 	GEN_EVT_CODE(_Read_EFUSE),
	GEN_EVT_CODE(_Read_CAM),			/*5*/
 	GEN_EVT_CODE(_Get_BasicRate),  
 	GEN_EVT_CODE(_Get_DataRate),   
 	GEN_EVT_CODE(_Survey),	 /*8*/
 	GEN_EVT_CODE(_SurveyDone),	 /*9*/
 	
 	GEN_EVT_CODE(_JoinBss) , /*10*/
 	GEN_EVT_CODE(_AddSTA),
 	GEN_EVT_CODE(_DelSTA),
 	GEN_EVT_CODE(_AtimDone) ,
 	GEN_EVT_CODE(_TX_Report),  
	GEN_EVT_CODE(_CCX_Report),			/*15*/
 	GEN_EVT_CODE(_DTM_Report),
 	GEN_EVT_CODE(_TX_Rate_Statistics),
 	GEN_EVT_CODE(_C2HLBK), 
 	GEN_EVT_CODE(_FWDBG),
	GEN_EVT_CODE(_C2HFEEDBACK),               /*20*/
	GEN_EVT_CODE(_ADDBA),
	GEN_EVT_CODE(_C2HBCN),
	GEN_EVT_CODE(_ReportPwrState),		//filen: only for PCIE, USB	
	GEN_EVT_CODE(_CloseRF),				//filen: only for PCIE, work around ASPM
 	MAX_C2HEVT
};


#ifdef _RTL8192C_CMD_C_		

struct fwevent wlanevents[] = 
{
	{0, dummy_event_callback}, 	/*0*/
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{0, &survey_event_callback},		/*8*/
	{sizeof (struct surveydone_event), &surveydone_event_callback},	/*9*/
		
	{0, &joinbss_event_callback},		/*10*/
	{sizeof(struct stassoc_event), &stassoc_event_callback},
	{sizeof(struct stadel_event), &stadel_event_callback},	
	{0, &atimdone_event_callback},
	{0, dummy_event_callback},
	{0, NULL},	/*15*/
	{0, NULL},
	{0, NULL},
	{0, NULL},
	{0, fwdbg_event_callback},
	{0, NULL},	 /*20*/
	{0, NULL},
	{0, NULL},	
	{0, &cpwm_event_callback},
};

#endif//_RTL8192C_CMD_C_


#endif


