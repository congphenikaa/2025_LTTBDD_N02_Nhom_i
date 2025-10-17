import 'package:app_nghenhac/common/helpers/is_dark_mode.dart';
import 'package:app_nghenhac/common/widgets/appbar/app_bar.dart';
import 'package:app_nghenhac/common/widgets/bottombar/bottom_bar.dart';
import 'package:app_nghenhac/common/widgets/drawer/app_drawer.dart';
import 'package:app_nghenhac/core/configs/assets/app_images.dart';
import 'package:app_nghenhac/core/configs/assets/app_vectors.dart';
import 'package:app_nghenhac/core/configs/theme/app_colors.dart';
import 'package:app_nghenhac/presentation/home/widgets/news_songs.dart';
import 'package:app_nghenhac/presentation/home/widgets/play_list.dart';
import 'package:app_nghenhac/presentation/profile/pages/profile.dart';
import 'package:app_nghenhac/presentation/search/bloc/search_cubit.dart';
import 'package:app_nghenhac/presentation/search/pages/search_page.dart';
import 'package:app_nghenhac/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedBottomBarIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  void _onBottomBarItemTapped(int index) {
    setState(() {
      _selectedBottomBarIndex = index;
    });

    switch (index) {
      case 0:
        // Đã ở Home, không cần làm gì
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => sl<SearchCubit>(),
              child: const SearchPage(),
            ),
          ),
        ).then((_) {
          setState(() {
            _selectedBottomBarIndex = 0;
          });
        });
        break;
      case 2:
        // TODO: Navigate to Library page
        // Navigator.push(context, MaterialPageRoute(builder: (context) => LibraryPage()));
        break;
      case 3:
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const ProfilePage())
        ).then((_) {
          // Reset selected index khi quay về
          setState(() {
            _selectedBottomBarIndex = 0;
          });
        });
        break;
    }
  }
  

  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BasicAppbar(
        hideBack: true,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => const SearchPage())
          );
          }, 
          icon: const Icon(
            Icons.search
          )
        ),
        title: SvgPicture.asset(
          AppVectors.logo,
          height: 40,
          width: 40,
        ),
        action: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            }, 
            icon: const Icon(
              Icons.menu
            )
          ),
        ),
      ),
      endDrawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _homeTopCard(),
            _tabs(),
            SizedBox(
              height: 260,
              child: TabBarView(
                controller: _tabController,
                children: [
                  const NewsSongs(),
                  Container(),
                  Container(),
                  Container(),
                ],
              ),
            ),
            const PlayList()
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBottomBar(
        selectedIndex: _selectedBottomBarIndex,
        onItemTapped: _onBottomBarItemTapped,
      ),
    );
  }

  Widget _homeTopCard(){
    return Center(
      child: SizedBox(
        height: 140,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: SvgPicture.asset(
                AppVectors.homeTopCard
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 60
                ),
                child: Image.asset(
                  AppImages.homeArtist,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tabs() {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    child: AnimatedBuilder(
      animation: _tabController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTabButton('News', 0),
            _buildTabButton('Videos', 1),
            _buildTabButton('Artists', 2),
            _buildTabButton('Podcasts', 3),
          ],
        );
      },
    ),
  );
}

Widget _buildTabButton(String text, int index) {
  final isSelected = _tabController.index == index;
  return GestureDetector(
    onTap: () {
      _tabController.animateTo(index);
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: isSelected 
          ? Border(bottom: BorderSide(color: AppColors.primary, width: 2))
          : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          fontSize: 14,
          color: isSelected 
            ? (context.isDarkMode ? Colors.white : Colors.black)
            : (context.isDarkMode ? Colors.white60 : Colors.black54),
        ),
      ),
    ),
  );
}


}