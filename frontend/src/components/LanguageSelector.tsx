import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { 
  IconButton, 
  Menu, 
  MenuItem, 
  ListItemText,
  Tooltip
} from '@mui/material';
import { Language } from '@mui/icons-material';

export function LanguageSelector() {
  const { i18n, t } = useTranslation();
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const open = Boolean(anchorEl);

  const handleClick = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const changeLanguage = (language: string) => {
    i18n.changeLanguage(language);
    handleClose();
  };

  return (
    <>
      <Tooltip title={t('language.select')}>
        <IconButton
          onClick={handleClick}
          color="inherit"
          aria-label={t('language.select')}
        >
          <Language />
        </IconButton>
      </Tooltip>
      <Menu
        anchorEl={anchorEl}
        open={open}
        onClose={handleClose}
      >
        <MenuItem onClick={() => changeLanguage('ko')} selected={i18n.language === 'ko'}>
          <ListItemText>{t('language.ko')}</ListItemText>
        </MenuItem>
        <MenuItem onClick={() => changeLanguage('en')} selected={i18n.language === 'en'}>
          <ListItemText>{t('language.en')}</ListItemText>
        </MenuItem>
        <MenuItem onClick={() => changeLanguage('ja')} selected={i18n.language === 'ja'}>
          <ListItemText>{t('language.ja')}</ListItemText>
        </MenuItem>
      </Menu>
    </>
  );
}
