import { useTranslation } from 'react-i18next';
import { Checkbox, IconButton, ListItem, ListItemButton, ListItemIcon, ListItemText, Tooltip } from '@mui/material';
import { Delete as DeleteIcon, Edit as EditIcon } from '@mui/icons-material';
import { Todo } from '../types/todo';

interface TodoItemProps {
  todo: Todo;
  onToggle: (id: string, completed: boolean) => void;
  onEdit: (todo: Todo) => void;
  onDelete: (id: string) => void;
}

export function TodoItem({ todo, onToggle, onEdit, onDelete }: TodoItemProps) {
  const { t } = useTranslation();
  
  return (
    <ListItem
      secondaryAction={
        <>
          <Tooltip title={t('todo.edit')}>
            <IconButton edge="end" aria-label={t('todo.edit')} onClick={() => onEdit(todo)}>
              <EditIcon />
            </IconButton>
          </Tooltip>
          <Tooltip title={t('todo.delete')}>
            <IconButton edge="end" aria-label={t('todo.delete')} onClick={() => onDelete(todo.id)}>
              <DeleteIcon />
            </IconButton>
          </Tooltip>
        </>
      }
      disablePadding
    >
      <ListItemButton role={undefined} onClick={() => onToggle(todo.id, !todo.completed)} dense>
        <ListItemIcon>
          <Checkbox
            edge="start"
            checked={todo.completed}
            tabIndex={-1}
            disableRipple
          />
        </ListItemIcon>
        <ListItemText
          primary={todo.title}
          secondary={todo.description}
          sx={{
            textDecoration: todo.completed ? 'line-through' : 'none',
          }}
        />
      </ListItemButton>
    </ListItem>
  );
}
