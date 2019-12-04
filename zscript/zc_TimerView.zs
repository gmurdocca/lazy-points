/* Copyright Alexander 'm8f' Kromm (mmaulwurff@gmail.com) 2019
 *
 * This file is a part of Zcore.
 *
 * Zcore is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * Zcore is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Zcore.  If not, see <https://www.gnu.org/licenses/>.
 */

class zc_TimerView
{

// public: /////////////////////////////////////////////////////////////////////

  zc_TimerView init(zc_Timer timer)
  {
    _timer = timer;

    return self;
  }

  ui
  int show(int y)
  {
    int    screenWidth  = Screen.GetWidth();
    double ratio        = double(_timer.GetCount()) / _timer.GetMaxCount();
    int    middleWidth  = screenWidth / 2;
    int    halfBarWidth = round(screenWidth / 8 * ratio);

    y += MARGIN;

    Screen.DrawThickLine( middleWidth - halfBarWidth, y
                        , middleWidth + halfBarWidth, y
                        , BAR_THICKNESS, BAR_COLOR
                        );

    return BAR_THICKNESS;
  }

// private: ////////////////////////////////////////////////////////////////////

  const BAR_THICKNESS = 2.0;
  const BAR_COLOR     = "gray";
  const MARGIN        = 10;

// private: ////////////////////////////////////////////////////////////////////

  private zc_Timer _timer;

} // class zc_TimerView