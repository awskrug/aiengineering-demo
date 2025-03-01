import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
} from '@mui/material';
import { Todo, UpdateTodoInput } from '../types/todo';

interface EditTodoDialogProps {
  todo: Todo | null;
  open: boolean;
  onClose: () => void;
  onSave: (input: UpdateTodoInput) => void;
}

export function EditTodoDialog({ todo, open, onClose, onSave }: EditTodoDialogProps) {
  const { t } = useTranslation();
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (todo) {
      setTitle(todo.title);
      setDescription(todo.description || '');
    }
  }, [todo]);

  const handleSave = () => {
    if (!todo || !title.trim()) return;

    onSave({
      id: todo.id,
      title: title.trim(),
      description: description.trim() || undefined,
    });
    onClose();
  };

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <DialogTitle>{t('todo.edit')}</DialogTitle>
      <DialogContent>
        <TextField
          autoFocus
          margin="dense"
          label={t('form.title')}
          type="text"
          fullWidth
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          required
        />
        <TextField
          margin="dense"
          label={t('form.description')}
          type="text"
          fullWidth
          multiline
          rows={3}
          value={description}
          onChange={(e) => setDescription(e.target.value)}
        />
      </DialogContent>
      <DialogActions>
        <Button onClick={onClose}>{t('form.cancel')}</Button>
        <Button onClick={handleSave} disabled={!title.trim()}>
          {t('form.save')}
        </Button>
      </DialogActions>
    </Dialog>
  );
}
