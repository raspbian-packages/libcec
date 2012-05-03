/*
 * This file is part of the libCEC(R) library.
 *
 * libCEC(R) is Copyright (C) 2011-2012 Pulse-Eight Limited.  All rights reserved.
 * libCEC(R) is an original work, containing original code.
 *
 * libCEC(R) is a trademark of Pulse-Eight Limited.
 *
 * This program is dual-licensed; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 *
 * Alternatively, you can license this library under a commercial license,
 * please contact Pulse-Eight Licensing for more information.
 *
 * For more information contact:
 * Pulse-Eight Licensing       <license@pulse-eight.com>
 *     http://www.pulse-eight.com/
 *     http://www.pulse-eight.net/
 */

#include "RLCommandHandler.h"
#include "../devices/CECBusDevice.h"
#include "../CECProcessor.h"
#include "../LibCEC.h"

using namespace CEC;
using namespace PLATFORM;

CRLCommandHandler::CRLCommandHandler(CCECBusDevice *busDevice) :
    CCECCommandHandler(busDevice)
{
  m_vendorId = CEC_VENDOR_TOSHIBA;
  CCECBusDevice *primary = m_processor->GetPrimaryDevice();

  /* imitate Toshiba devices */
  if (primary && m_busDevice->GetLogicalAddress() != primary->GetLogicalAddress())
  {
    primary->SetVendorId(CEC_VENDOR_TOSHIBA);
    primary->ReplaceHandler(false);
  }
}

bool CRLCommandHandler::InitHandler(void)
{
  if (m_bHandlerInited)
    return true;
  m_bHandlerInited = true;

  if (m_busDevice->GetLogicalAddress() == CECDEVICE_TV)
  {
    CCECBusDevice *primary = m_processor->GetPrimaryDevice();

    /* send the vendor id */
    primary->TransmitVendorID(CECDEVICE_BROADCAST);
  }

  return true;
}
