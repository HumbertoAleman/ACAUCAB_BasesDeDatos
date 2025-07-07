"use client"

import React from "react"
import { AppBar, Toolbar, Typography, Box, Menu, MenuItem, IconButton, Avatar, Chip } from "@mui/material"
import { ExitToApp, Person, ShoppingCart } from "@mui/icons-material"
import { useAuth } from "../../contexts/AuthContext"
import { useCart } from '../../contexts/CartContext'
import { useNavigate } from 'react-router-dom'
import Badge from '@mui/material/Badge'

interface NavbarProps {
  onCartClick?: () => void;
}

export const Navbar: React.FC<NavbarProps> = ({ onCartClick }) => {
  const { user, logout } = useAuth()
  const [anchorEl, setAnchorEl] = React.useState<null | HTMLElement>(null)
  const { items } = useCart()
  const navigate = useNavigate()

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget)
  }

  const handleClose = () => {
    setAnchorEl(null)
  }

  const handleLogout = () => {
    logout()
    handleClose()
  }

  return (
    <AppBar position="static" sx={{ backgroundColor: "#2E7D32" }}>
      <Toolbar sx={{ justifyContent: 'space-between' }}>
        <Typography variant="h6" component="div" sx={{ fontWeight: "bold" }}>
          ACAUCAB - Sistema de Gestión
        </Typography>

        {user && (
          <Box sx={{ display: "flex", alignItems: "center" }}>
            <Box sx={{ display: "flex", flexDirection: "column", alignItems: "flex-end", mr: 1 }}>
              <Typography variant="body2" sx={{ fontWeight: 500 }}>
                {user.username}
              </Typography>
              {user.rol && (
                <Chip
                  label={user.rol}
                  size="small"
                  sx={{
                    backgroundColor: "rgba(255,255,255,0.2)",
                    color: "white",
                    fontSize: "0.7rem",
                    height: 20,
                  }}
                />
              )}
            </Box>
            <IconButton
              size="large"
              aria-label="account of current user"
              aria-controls="menu-appbar"
              aria-haspopup="true"
              onClick={handleMenu}
              color="inherit"
              sx={{ mr: 0.5 }}
            >
              <Avatar sx={{ width: 32, height: 32, backgroundColor: "#1B5E20" }}>
                {user && user.username ? user.username.charAt(0).toUpperCase() : <Person />}
              </Avatar>
            </IconButton>
            {user.fk_clie && (
              <IconButton color="inherit" sx={{ ml: 0 }} onClick={onCartClick}>
                <Badge badgeContent={items.length} color="error">
                  <ShoppingCart />
                </Badge>
              </IconButton>
            )}
            <Menu
              id="menu-appbar"
              anchorEl={anchorEl}
              anchorOrigin={{
                vertical: "bottom",
                horizontal: "right",
              }}
              keepMounted
              transformOrigin={{
                vertical: "top",
                horizontal: "right",
              }}
              open={Boolean(anchorEl)}
              onClose={handleClose}
            >
              <MenuItem disabled>
                <Person sx={{ mr: 1 }} />
                {user.username}
              </MenuItem>
              {user.rol && (
                <MenuItem disabled>
                  <Typography variant="caption" color="text.secondary">
                    {user.rol}
                  </Typography>
                </MenuItem>
              )}
              <MenuItem onClick={handleLogout}>
                <ExitToApp sx={{ mr: 1 }} />
                Cerrar Sesión
              </MenuItem>
            </Menu>
          </Box>
        )}
      </Toolbar>
    </AppBar>
  )
}
